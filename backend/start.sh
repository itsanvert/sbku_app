#!/bin/bash

set -e

# ── ECS / Container metadata ─────────────────────────────────────────────
log() { echo "[$(date -Iseconds)] $*"; }
warn() { echo "[$(date -Iseconds)] WARNING: $*" >&2; }
error() { echo "[$(date -Iseconds)] ERROR: $*" >&2; }

ECS_CONTAINER_METADATA_URI_V4="${ECS_CONTAINER_METADATA_URI_V4:-}"
if [ -n "$ECS_CONTAINER_METADATA_URI_V4" ]; then
    log "Running on AWS ECS (Fargate/EC2) — metadata URI available"
fi

# ── Graceful shutdown trap ───────────────────────────────────────────────
# ECS sends SIGTERM, then SIGKILL after the stop timeout (default 30s).
# We forward the signal to all child processes and wait for them.
cleanup() {
    local signal=$1
    log "Received $signal — shutting down gracefully..."
    if [ -n "$NGINX_PID" ] && kill -0 "$NGINX_PID" 2>/dev/null; then
        log "Stopping nginx (PID $NGINX_PID)..."
        nginx -s quit 2>/dev/null || kill -TERM "$NGINX_PID" 2>/dev/null || true
    fi
    if [ -n "$APACHE_PID" ] && kill -0 "$APACHE_PID" 2>/dev/null; then
        log "Stopping Apache (PID $APACHE_PID)..."
        kill -TERM "$APACHE_PID" 2>/dev/null || true
    fi
    if [ -n "$QUEUE_PID" ] && kill -0 "$QUEUE_PID" 2>/dev/null; then
        log "Stopping queue worker (PID $QUEUE_PID)..."
        kill -TERM "$QUEUE_PID" 2>/dev/null || true
    fi
    wait
    log "Shutdown complete."
    exit 0
}
trap 'cleanup SIGTERM' TERM

trap 'cleanup SIGINT' INT

trap 'cleanup SIGQUIT' QUIT

# ── Ensure .env exists ──────────────────────────────────────────────────────
if [ ! -f /var/www/html/.env ]; then
    warn "No .env file found — creating minimal fallback..."
    cat > /var/www/html/.env << 'ENVEOF'
APP_NAME=SBKU
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://localhost
DB_CONNECTION=sqlite
DB_DATABASE=/var/data/database.sqlite
ENVEOF
fi

# Generate APP_KEY if missing or still has placeholder value
APP_KEY_VAL=$(grep '^APP_KEY=' /var/www/html/.env 2>/dev/null | cut -d= -f2- || true)
if [ -z "$APP_KEY_VAL" ] || echo "$APP_KEY_VAL" | grep -q "YOUR_APP_KEY_HERE\|^APP_KEY=$" 2>/dev/null; then
    log "APP_KEY is missing or has placeholder — generating..."
    sed -i '/^APP_KEY=/d' /var/www/html/.env
    NEW_KEY=$(php /var/www/html/artisan key:generate --show 2>/dev/null || echo "")
    if [ -n "$NEW_KEY" ]; then
        echo "APP_KEY=$NEW_KEY" >> /var/www/html/.env
        log "APP_KEY generated successfully."
    else
        error "Failed to generate APP_KEY"
    fi
fi

# ── Write ECS secrets / env vars into .env ──────────────────────────────
# ECS task definition provides these via "environment" or "secrets" (SSM).
# We overlay them on .env so Laravel can read them via $_ENV / getenv().
write_env() {
    local key="$1"
    local val="$2"
    if [ -n "$val" ]; then
        # Remove existing line, append new one
        sed -i "/^${key}=/d" /var/www/html/.env 2>/dev/null || true
        echo "${key}=${val}" >> /var/www/html/.env
    fi
}

write_env "APP_ENV" "${APP_ENV:-production}"
write_env "APP_DEBUG" "${APP_DEBUG:-false}"
write_env "APP_URL" "${APP_URL:-http://localhost}"
write_env "DB_CONNECTION" "${DB_CONNECTION:-pgsql}"
write_env "DB_HOST" "${DB_HOST:-}"
write_env "DB_PORT" "${DB_PORT:-5432}"
write_env "DB_DATABASE" "${DB_DATABASE:-}"
write_env "DB_USERNAME" "${DB_USERNAME:-}"
write_env "DB_PASSWORD" "${DB_PASSWORD:-}"
write_env "DB_SSLMODE" "${DB_SSLMODE:-require}"
write_env "SESSION_DRIVER" "${SESSION_DRIVER:-file}"
write_env "CACHE_STORE" "${CACHE_STORE:-file}"
write_env "FILESYSTEM_DISK" "${FILESYSTEM_DISK:-public}"
write_env "QUEUE_CONNECTION" "${QUEUE_CONNECTION:-sync}"
write_env "LOG_LEVEL" "${LOG_LEVEL:-error}"
write_env "USE_FIRESTORE" "${USE_FIRESTORE:-false}"

if [ -n "$NEON_DATABASE_URL" ]; then
    write_env "NEON_DATABASE_URL" "$NEON_DATABASE_URL"
    log "NEON_DATABASE_URL provided — PostgreSQL will be configured via start.sh logic"
fi

if [ -n "$DATABASE_URL" ]; then
    write_env "DATABASE_URL" "$DATABASE_URL"
fi

# ── Neon (serverless Postgres) auto-parsing ──────────────────────────
# Only parse NEON_DATABASE_URL if DB_HOST is NOT already set (secrets take priority)
if [ -n "$NEON_DATABASE_URL" ] && [ -z "$DB_HOST" ]; then
    log "Parsing NEON_DATABASE_URL for PostgreSQL connection..."
    NEON_URL="$(printf '%s' "$NEON_DATABASE_URL")"
    NEON_URL="${NEON_URL//[$'\t\r\n\"\'\\']/}"
    WITHOUT_PROTO="${NEON_URL#*://}"
    CREDS_AND_HOST="${WITHOUT_PROTO%%\?*}"
    USER_PASS="${CREDS_AND_HOST%%@*}"
    HOST_DB="${CREDS_AND_HOST#*@}"
    DB_USER="${USER_PASS%%:*}"
    DB_PASS="${USER_PASS#*:}"
    DB_HOST_PORT="${HOST_DB%%/*}"
    DB_NAME="${HOST_DB#*/}"
    DB_HOST_VAL="${DB_HOST_PORT%%:*}"
    DB_PORT_VAL="${DB_HOST_PORT#*:}"
    [ "$DB_HOST_VAL" = "$DB_PORT_VAL" ] && DB_PORT_VAL="5432"

    write_env "DB_CONNECTION" "pgsql"
    write_env "DB_HOST" "$DB_HOST_VAL"
    write_env "DB_PORT" "$DB_PORT_VAL"
    write_env "DB_DATABASE" "$DB_NAME"
    write_env "DB_USERNAME" "$DB_USER"
    write_env "DB_PASSWORD" "$DB_PASS"
    write_env "DB_SSLMODE" "require"
    log "Neon PostgreSQL configured: host=$DB_HOST_VAL port=$DB_PORT_VAL db=$DB_NAME user=$DB_USER"
fi

# PostgreSQL keepalive — prevents Neon serverless from suspending between queries
export PGKEEPALIVESIDLE=60
export PGKEEPALIVESINTERVAL=10
export PGKEEPALIVESCOUNT=5

# ── SQLite fallback ────────────────────────────────────────────────────
if [ "$DB_CONNECTION" = "sqlite" ]; then
    unset DATABASE_URL || true
    write_env "DB_HOST" ""
    write_env "DB_PORT" ""
    write_env "DB_USERNAME" ""
    write_env "DB_PASSWORD" ""
    mkdir -p database
    touch database/database.sqlite
fi

# ── Storage directories ─────────────────────────────────────────────────
mkdir -p storage/framework/sessions storage/framework/views storage/framework/cache/data storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

SESSION_DIR="${SESSION_FILES:-/var/data/sessions}"
CACHE_DIR="${CACHE_FILE_PATH:-/var/data/cache}"
mkdir -p "$SESSION_DIR" "$CACHE_DIR"
chown www-data:www-data "$SESSION_DIR" "$CACHE_DIR"
chmod 775 "$SESSION_DIR" "$CACHE_DIR"

# ── Firebase credentials ────────────────────────────────────────────────
if [ -f "/etc/secrets/firebase-credentials.json" ]; then
    log "Found Firebase credentials in /etc/secrets, preparing for use..."
    mkdir -p storage/app
    cp /etc/secrets/firebase-credentials.json storage/app/firebase-credentials.json
    chmod 644 storage/app/firebase-credentials.json
    export FIREBASE_CREDENTIALS="storage/app/firebase-credentials.json"
    export GOOGLE_APPLICATION_CREDENTIALS="/var/www/html/storage/app/firebase-credentials.json"
    [ -z "$USE_FIRESTORE" ] && export USE_FIRESTORE="true"
    if [ -z "$DB_HOST" ] && [ "$DB_CONNECTION" != "pgsql" ] && [ "$DB_CONNECTION" != "mysql" ] && [ "$DB_CONNECTION" != "mariadb" ]; then
        export DB_CONNECTION="sqlite"
        write_env "DB_CONNECTION" "sqlite"
        write_env "DB_DATABASE" "/var/data/database.sqlite"
        unset DATABASE_URL
    fi
elif [ -n "$FIREBASE_CREDENTIALS_JSON" ]; then
    log "Found FIREBASE_CREDENTIALS_JSON env var, creating file..."
    mkdir -p storage/app
    echo "$FIREBASE_CREDENTIALS_JSON" > storage/app/firebase-credentials.json
    chmod 644 storage/app/firebase-credentials.json
    export FIREBASE_CREDENTIALS="storage/app/firebase-credentials.json"
    export GOOGLE_APPLICATION_CREDENTIALS="/var/www/html/storage/app/firebase-credentials.json"
    [ -z "$USE_FIRESTORE" ] && export USE_FIRESTORE="true"
    if [ -z "$DB_HOST" ] && [ "$DB_CONNECTION" != "pgsql" ] && [ "$DB_CONNECTION" != "mysql" ] && [ "$DB_CONNECTION" != "mariadb" ]; then
        export DB_CONNECTION="sqlite"
        write_env "DB_CONNECTION" "sqlite"
        write_env "DB_DATABASE" "/var/data/database.sqlite"
        unset DATABASE_URL
    fi
fi

# ── Database migrations ────────────────────────────────────────────────
if [ "$USE_FIRESTORE" = "true" ] && [ "$DB_CONNECTION" = "sqlite" ]; then
    log "USE_FIRESTORE=true with SQLite — skipping database migrations"
    DB_PATH="${DB_DATABASE:-/var/data/database.sqlite}"
    DB_DIR=$(dirname "$DB_PATH")
    mkdir -p "$DB_DIR"
    touch "$DB_PATH"
    log "Created empty SQLite database at $DB_PATH"
elif [ "$DB_CONNECTION" = "sqlite" ]; then
    php artisan migrate --force --database=sqlite 2>/dev/null || warn "SQLite migration failed"
else
    php artisan migrate --force 2>/dev/null || warn "Database migration failed (tables may be stale)"
fi

php artisan storage:link --force 2>/dev/null || php artisan storage:link 2>/dev/null || true

# ── OPcache ──────────────────────────────────────────────────────────────
if [ "$PHP_OPCACHE_ENABLE" = "1" ] || [ "$APP_ENV" = "production" ]; then
    log "Configuring and enabling PHP OPcache..."
    OPCACHE_INI="/usr/local/etc/php/conf.d/docker-php-ext-opcache.ini"
    docker-php-ext-enable opcache 2>/dev/null || true
    cat <<EOF > "$OPCACHE_INI"
[opcache]
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=20000
opcache.revalidate_freq=0
opcache.validate_timestamps=0
opcache.fast_shutdown=1
opcache.jit_buffer_size=100M
opcache.jit=tracing
EOF
    log "OPcache configured with JIT enabled."
fi

rm -f bootstrap/cache/packages.php
php artisan package:discover --ansi 2>/dev/null || true
php artisan optimize 2>/dev/null || warn "Optimize failed (config/route/event cache skipped)"

if [ -z "$(find storage/framework/views/ -maxdepth 1 -name '*.php' 2>/dev/null | head -1)" ]; then
    php artisan view:cache 2>/dev/null || warn "View cache failed (templates compile on demand)"
fi

chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# ── Apache: configure to listen on port 8080 for nginx proxy ─────────────
APACHE_PORTS="/etc/apache2/ports.conf"
APACHE_SITE="/etc/apache2/sites-available/000-default.conf"

log "Configuring Apache to listen on port 8080..."
sed -ni '/^Listen /!p' "$APACHE_PORTS"
echo "Listen 8080" >> "$APACHE_PORTS"

sed -i 's/:[0-9]\+>/:8080>/g' "$APACHE_SITE" 2>/dev/null || true

echo "ServerName _default_" >> /etc/apache2/apache2.conf || true
echo "UseCanonicalName Off" >> /etc/apache2/apache2.conf || true

# Stop any stale Apache on old port 80
if [ -s /var/log/apache2/httpd.pid ] || ps aux | grep -v grep | grep -q '[a]pache2'; then
    log "Stopping existing Apache process..."
    pkill -TERM apache2 2>/dev/null || true
    sleep 2
fi

# ── PHP-FPM pool tuning ──────────────────────────────────────────────────
PHPFPM_POOL="/usr/local/etc/php-fpm.d/www.conf"
if [ -f "$PHPFPM_POOL" ]; then
    sed -i 's/^pm = .*/pm = dynamic/' "$PHPFPM_POOL" 2>/dev/null || true
    sed -i 's/^pm.max_children = .*/pm.max_children = 10/' "$PHPFPM_POOL" 2>/dev/null || true
    sed -i 's/^pm.start_servers = .*/pm.start_servers = 3/' "$PHPFPM_POOL" 2>/dev/null || true
    sed -i 's/^pm.min_spare_servers = .*/pm.min_spare_servers = 3/' "$PHPFPM_POOL" 2>/dev/null || true
    sed -i 's/^pm.max_spare_servers = .*/pm.max_spare_servers = 5/' "$PHPFPM_POOL" 2>/dev/null || true
fi

# ── PHP-FPM (optional — only starts if binary exists) ─────────────────────
if [ -x "$(command -v php-fpm 2>/dev/null)" ]; then
    log "Starting PHP-FPM..."
    php-fpm -y /usr/local/etc/php-fpm.conf &
    sleep 1
else
    log "PHP-FPM not available — Apache uses mod_php (no php-fpm needed)."
fi

# ── Flutter web build check ───────────────────────────────────────────────
if [ -z "$(find /var/www/html/build/web -maxdepth 0 -type d 2>/dev/null)" ]; then
    warn "/var/www/html/build/web/ not found — Flutter web build was not copied into the image."
fi

if [ ! -f /var/www/html/build/web/index.html ]; then
    log "No Flutter index.html found — creating placeholder page..."
    cat > /var/www/html/build/web/index.html << 'PLACEHOLDER'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SBKU App</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; display: flex; align-items: center; justify-content: center; min-height: 100vh; background: #f5f5f5; }
        .container { text-align: center; padding: 2rem; }
        h1 { font-size: 2rem; color: #333; margin-bottom: 0.5rem; }
        p { color: #666; font-size: 1.1rem; }
        .status { display: inline-block; margin-top: 1rem; padding: 0.5rem 1.5rem; background: #10b981; color: white; border-radius: 6px; font-weight: 500; }
    </style>
</head>
<body>
    <div class="container">
        <h1>SBKU App</h1>
        <p>Backend is running</p>
        <div class="status">API Available</div>
    </div>
</body>
</html>
PLACEHOLDER
fi

# ── Queue worker ─────────────────────────────────────────────────────────
if [ -z "$WEB_ONLY" ]; then
    php artisan queue:work --queue=default --sleep=3 --tries=3 --max-time=3600 &
    QUEUE_PID=$!
    log "Queue worker started (PID $QUEUE_PID)."
else
    log "WEB_ONLY set — skipping queue worker."
fi

# ── Start Apache on port 8080 in background ──────────────────────────────
log "Starting Apache on port 8080..."
apache2-foreground &
APACHE_PID=$!
sleep 3

# Wait for Apache to start listening (up to 15s)
APACHE_READY=false
for i in 1 2 3 4 5; do
    if command -v ss &> /dev/null; then
        if ss -tlnp 2>/dev/null | grep -q ':8080'; then
            log "✓ Apache listening on port 8080"; APACHE_READY=true; break
        fi
    elif command -v netstat &> /dev/null; then
        if netstat -tlnp 2>/dev/null | grep -q ':8080'; then
            log "✓ Apache listening on port 8080"; APACHE_READY=true; break
        fi
    fi
    # Fallback: check if PID is still alive
    if ! kill -0 "$APACHE_PID" 2>/dev/null; then
        error "Apache process (PID $APACHE_PID) died prematurely!"
        error "Check Apache error logs: docker exec <container> cat /var/log/apache2/error.log"
        APACHE_READY=false
        break
    fi
    [ "$i" -eq 5 ] && warn "Apache NOT listening on port 8080 after 15s — check config"
    sleep 3
done

# Quick Apache connectivity test (retry a few times)
if [ "$APACHE_READY" = true ] && command -v curl &> /dev/null; then
    for i in 1 2 3; do
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/ 2>/dev/null || echo "000")
        if [ "$HTTP_CODE" != "000" ]; then
            log "Apache reachable on 8080 (HTTP $HTTP_CODE)"
            break
        fi
        [ "$i" -eq 3 ] && warn "Apache unreachable on 8080 after 3 attempts"
        sleep 2
    done
fi

if [ "$APACHE_READY" = false ]; then
    error "Apache is not running — nginx will return 502 Bad Gateway for all proxied requests."
    error "Check Apache error logs: docker exec <container> cat /var/log/apache2/error.log"
    error "Check PHP error logs: docker exec <container> cat /var/www/html/storage/logs/laravel.log"
fi

# ── Start nginx as the foreground entrypoint ──────────────────────────────
log "Starting nginx on port ${PORT:-80}..."
if [ -f /var/run/nginx.pid ] && kill -0 "$(cat /var/run/nginx.pid)" 2>/dev/null; then
    log "nginx already running."
else
    nginx -g "daemon off;" &
    NGINX_PID=$!
    sleep 1
    if kill -0 $NGINX_PID 2>/dev/null; then
        log "✓ nginx is PID $NGINX_PID"
    else
        error "nginx failed to start — falling back to Apache only"
        wait $APACHE_PID
    fi
fi

log "SBKU backend is fully operational."

# Block so the container stays alive (handles signals via trap)
wait $NGINX_PID || wait $APACHE_PID
