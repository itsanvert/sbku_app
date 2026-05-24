#!/bin/bash

# Exit on error
set -e

# ── Ensure .env exists ──────────────────────────────────────────────────────
# .env is created at build time by the Dockerfile from .env.example with real
# DB credentials. At runtime, just generate APP_KEY if missing.
if [ ! -f /var/www/html/.env ]; then
    echo "WARNING: No .env file found — creating minimal fallback..."
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
if [ -z "$APP_KEY_VAL" ] || echo "$APP_KEY_VAL" | grep -q "YOUR_APP_KEY_HERE" 2>/dev/null; then
    echo "APP_KEY is missing or has placeholder — generating..."
    # Remove the placeholder line first so artisan can generate cleanly
    sed -i '/^APP_KEY=/d' /var/www/html/.env
    NEW_KEY=$(php /var/www/html/artisan key:generate --show 2>/dev/null || echo "")
    if [ -n "$NEW_KEY" ]; then
        echo "APP_KEY=$NEW_KEY" >> /var/www/html/.env
        echo "APP_KEY generated successfully."
    else
        echo "WARNING: Failed to generate APP_KEY"
    fi
fi

# Normalize DB_CONNECTION: strip CR/LF and quotes, make lowercase so comparisons work
if [ -n "$DB_CONNECTION" ]; then
    DB_CONNECTION="$(printf '%s' "$DB_CONNECTION" | tr -d '\r' | tr -d '"' | tr -d "'" | tr '[:upper:]' '[:lower:]')"
fi

# If DB_DATABASE references a sqlite file, prefer sqlite connection
if [ -n "$DB_DATABASE" ] && printf '%s' "$DB_DATABASE" | grep -qi "sqlite"; then
    DB_CONNECTION=sqlite
fi

# ── Neon (serverless Postgres) ────────────────────────────────
if [ -n "$NEON_DATABASE_URL" ]; then
    echo "Detected NEON_DATABASE_URL — switching to PostgreSQL (Neon)..."
    NEON_URL="$(printf '%s' "$NEON_DATABASE_URL" | tr -d '\r' | tr -d '\n' | tr -d '"' | tr -d "'")"
    # Strip postgresql:// prefix
    WITHOUT_PROTO="${NEON_URL#*://}"
    # Extract credentials and host/db
    CREDS_AND_HOST="${WITHOUT_PROTO%%\?*}"
    # user:pass@host:port/db
    USER_PASS="${CREDS_AND_HOST%%@*}"
    HOST_DB="${CREDS_AND_HOST#*@}"
    DB_USER="${USER_PASS%%:*}"
    DB_PASS="${USER_PASS#*:}"
    DB_HOST_PORT="${HOST_DB%%/*}"
    DB_NAME="${HOST_DB#*/}"
    # Split host:port
    DB_HOST_VAL="${DB_HOST_PORT%%:*}"
    DB_PORT_VAL="${DB_HOST_PORT#*:}"
    [ "$DB_HOST_VAL" = "$DB_PORT_VAL" ] && DB_PORT_VAL="5432"

    export DB_CONNECTION="pgsql"
    # NOTE: Do NOT set DATABASE_URL — it passes ?sslmode=require as a query
    # string that conflicts with DB_SSLMODE=require in Laravel's connector.
    export DB_HOST="$DB_HOST_VAL"
    export DB_PORT="$DB_PORT_VAL"
    export DB_DATABASE="$DB_NAME"
    export DB_USERNAME="$DB_USER"
    export DB_PASSWORD="$DB_PASS"
    export DB_SSLMODE="require"
    echo "Neon PostgreSQL configured: host=$DB_HOST_VAL port=$DB_PORT_VAL db=$DB_NAME user=$DB_USER"
fi

# Sanitize DATABASE_URL and DB_HOST to remove stray CR/LF or quotes
if [ -n "$DATABASE_URL" ]; then
    DATABASE_URL="$(printf '%s' "$DATABASE_URL" | tr -d '\r' | tr -d '\n' | tr -d '"' | tr -d "'" )"
    export DATABASE_URL
fi
if [ -n "$DB_HOST" ]; then
    DB_HOST="$(printf '%s' "$DB_HOST" | tr -d '\r' | tr -d '\n' | tr -d '"' | tr -d "'" )"
    export DB_HOST
fi

# If we're using sqlite, ensure no DATABASE_URL or remote DB vars override connection
if [ "$DB_CONNECTION" = "sqlite" ]; then
    unset DATABASE_URL || true
    export DB_HOST=""
    export DB_PORT=""
    export DB_USERNAME=""
    export DB_PASSWORD=""
    # leave DB_DATABASE pointing to the sqlite file
fi

# Create sqlite database if it doesn't exist (if still using it)
if [ "$DB_CONNECTION" = "sqlite" ]; then
    mkdir -p database
    touch database/database.sqlite
fi

# Ensure storage directories exist and are writable
mkdir -p storage/framework/sessions storage/framework/views storage/framework/cache/data storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Create session / cache directories and set www-data ownership
SESSION_DIR="${SESSION_FILES:-/var/data/sessions}"
CACHE_DIR="${CACHE_FILE_PATH:-/var/data/cache}"
mkdir -p "$SESSION_DIR" "$CACHE_DIR"
chown www-data:www-data "$SESSION_DIR" "$CACHE_DIR"
chmod 775 "$SESSION_DIR" "$CACHE_DIR"

# Set up Firebase credentials from secrets mount
if [ -f "/etc/secrets/firebase-credentials.json" ]; then
    echo "Found Firebase credentials in /etc/secrets, preparing for use..."
    mkdir -p storage/app
    cp /etc/secrets/firebase-credentials.json storage/app/firebase-credentials.json
    chmod 644 storage/app/firebase-credentials.json
    export FIREBASE_CREDENTIALS="storage/app/firebase-credentials.json"
    export GOOGLE_APPLICATION_CREDENTIALS="/var/www/html/storage/app/firebase-credentials.json"
    if [ -z "$USE_FIRESTORE" ]; then
        export USE_FIRESTORE="true"
    fi
    # Fall back to SQLite only if no external DB host is configured
    if [ -z "$DB_HOST" ] && [ "$DB_CONNECTION" != "pgsql" ] && [ "$DB_CONNECTION" != "mysql" ] && [ "$DB_CONNECTION" != "mariadb" ]; then
        export DB_CONNECTION="sqlite"
        export DB_DATABASE="/var/data/database.sqlite"
        unset DATABASE_URL
    fi
elif [ -n "$FIREBASE_CREDENTIALS_JSON" ]; then
    echo "Found FIREBASE_CREDENTIALS_JSON env var, creating file..."
    mkdir -p storage/app
    echo "$FIREBASE_CREDENTIALS_JSON" > storage/app/firebase-credentials.json
    chmod 644 storage/app/firebase-credentials.json
    export FIREBASE_CREDENTIALS="storage/app/firebase-credentials.json"
    export GOOGLE_APPLICATION_CREDENTIALS="/var/www/html/storage/app/firebase-credentials.json"
    if [ -z "$USE_FIRESTORE" ]; then
        export USE_FIRESTORE="true"
    fi
    # Fall back to SQLite only if no external DB host is configured
    if [ -z "$DB_HOST" ] && [ "$DB_CONNECTION" != "pgsql" ] && [ "$DB_CONNECTION" != "mysql" ] && [ "$DB_CONNECTION" != "mariadb" ]; then
        export DB_CONNECTION="sqlite"
        export DB_DATABASE="/var/data/database.sqlite"
        unset DATABASE_URL
    fi
fi

# Run migrations (skip only when using SQLite with Firestore)
# NOTE: If migration fails, log a warning but DO NOT block Apache startup.
# A 502 from a crashed container is worse than a running app with stale schema.
if [ "$USE_FIRESTORE" = "true" ] && [ "$DB_CONNECTION" = "sqlite" ]; then
    echo "USE_FIRESTORE is true with SQLite - skipping database migrations"
    DB_PATH="${DB_DATABASE:-/var/data/database.sqlite}"
    DB_DIR=$(dirname "$DB_PATH")
    mkdir -p "$DB_DIR"
    touch "$DB_PATH"
    echo "Created empty SQLite database at $DB_PATH"
elif [ "$DB_CONNECTION" = "sqlite" ]; then
    php artisan migrate --force --database=sqlite 2>/dev/null || echo "Warning: SQLite migration failed"
else
    php artisan migrate --force 2>/dev/null || echo "Warning: database migration failed (tables may be stale)"
fi

# Public storage symlink for profile images (idempotent)
php artisan storage:link --force 2>/dev/null || php artisan storage:link 2>/dev/null || true

# Enable and optimize PHP OPcache for fast production API performance
if [ "$PHP_OPCACHE_ENABLE" = "1" ] || [ "$APP_ENV" = "production" ]; then
    echo "Configuring and enabling PHP OPcache for maximum API response speed..."
    OPCACHE_INI="/usr/local/etc/php/conf.d/docker-php-ext-opcache.ini"
    docker-php-ext-enable opcache 2>/dev/null || true
    cat <<EOF > "$OPCACHE_INI"
[opcache]
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=20000
opcache.revalidate_freq=0
opcache.validate_timestamps=0
opcache.fast_shutdown=1
EOF
    echo "OPcache successfully configured and active."
fi

# Discover package service providers (Firebase, Livewire, Flux, etc.)
php artisan package:discover --ansi 2>/dev/null || true

# Cache Laravel configurations, routes, and events for maximum production speed
# NOTE: Do NOT block startup if this fails — Apache must always start
php artisan optimize 2>/dev/null || echo "Warning: optimize failed (config/route/event cache skipped)"

# Compile Blade templates only if not already cached (saves ~7s on restarts when
# the view cache was pre-built at Docker build time or persisted across restarts).
if [ -z "$(find storage/framework/views/ -maxdepth 1 -name '*.php' 2>/dev/null | head -1)" ]; then
    php artisan view:cache 2>/dev/null || echo "Warning: view cache failed (templates compile on demand)"
fi

# Re-apply storage ownership because php artisan optimize may create new files as root
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Configure Apache to listen on the runtime port ($PORT env var or default 80)
LISTEN_PORT="${PORT:-80}"
sed -i "s/\${PORT}/$LISTEN_PORT/g" /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf || true
# NOTE: Do NOT add a sed replacing bare "80" here — it corrupts port numbers
# (e.g., "8080" contains two non-overlapping "80" substrings, causing doubling).

# Set ServerName globally to suppress Apache qualified domain name warning
# UseCanonicalName Off ensures PHP uses the real Host header, not ServerName
echo "ServerName _default_" >> /etc/apache2/apache2.conf || true
echo "UseCanonicalName Off" >> /etc/apache2/apache2.conf || true

# ── Phase 1: Start Apache on port 8080 on behalf of nginx ─────────────────────
# Reconfigure Apache to listen on 8080 so nginx (port 80) → proxy → Apache (8080)
# This avoids two processes binding the same port, giving nginx full routing control.
sed -ri \
    -e 's/^Listen 80$/Listen 8080/' \
    -e 's/:80>/:8080>/' \
    /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf || true

if [ -s /var/log/apache2/httpd.pid ] || ps aux | grep -v grep | grep -q '[a]pache2'; then
    # Stop any Apache (port 80) already running so sed above takes effect
    # (docker-php-ext-install may have pre-warmed it, or the base image spawns it)
    pkill -TERM apache2 2>/dev/null || true
    sleep 1
fi

# Rewrite PHP-FPM pool to use dynamic so pm.max_children = 10 is safe on t3.micro
PHPFPM_POOL="/usr/local/etc/php-fpm.d/www.conf"
if [ -f "$PHPFPM_POOL" ]; then
    sed -i 's/^pm = .*/pm = dynamic/' "$PHPFPM_POOL" 2>/dev/null || true
    sed -i 's/^pm.max_children = .*/pm.max_children = 10/' "$PHPFPM_POOL" 2>/dev/null || true
    sed -i 's/^pm.start_servers = .*/pm.start_servers = 3/' "$PHPFPM_POOL" 2>/dev/null || true
    sed -i 's/^pm.min_spare_servers = .*/pm.min_spare_servers = 3/' "$PHPFPM_POOL" 2>/dev/null || true
    sed -i 's/^pm.max_spare_servers = .*/pm.max_spare_servers = 5/' "$PHPFPM_POOL" 2>/dev/null || true
fi

# Start PHP-FPM in background (for nginx → php-fpm fastcgi, alternative to Apache)
php-fpm -y /usr/local/etc/php-fpm.conf 2>/dev/null &
PHPFPM_PID=$!
sleep 1

# Ensure nginx compile-time config exists (if not, create it)
if [ ! -f /etc/nginx/nginx.conf ]; then
    echo "WARNING: /etc/nginx/nginx.conf not found — nginx install may have failed."
fi

# Flutter web build directory check (must exist from Docker COPY or Dockerfile stage)
if [ -z "$(find /var/www/html/build/web -maxdepth 0 -type d 2>/dev/null)" ]; then
    echo "WARNING: /var/www/html/build/web/ not found — Flutter web build was not copied into the image."
    echo "         Run flutter build web --release and rebuild the Docker image."
fi

# If index.html is missing from Flutter build, create a placeholder so nginx doesn't 403
if [ ! -f /var/www/html/build/web/index.html ]; then
    echo "No Flutter index.html found — creating placeholder page..."
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

# ── Phase 2: Queue worker & Apache ────────────────────────────────────────────
# Start queue worker in the background (skip if WEB_ONLY is set)
if [ -z "$WEB_ONLY" ]; then
    php artisan queue:work --queue=default --sleep=3 --tries=3 --max-time=3600 &
    echo "Queue worker started."
else
    echo "WEB_ONLY set — skipping queue worker."
fi

# Start Apache on port 8080 in background (if nginx → php-fpm is not used)
# Apache stays running only for legacy uses; nginx handles all incoming traffic.
apache2-foreground &
APACHE_PID=$!
sleep 2

# ── Phase 3: Start nginx as the foreground entrypoint ──────────────────────────
echo "Starting nginx on port ${PORT:-80} ..."
if [ -f /var/run/nginx.pid ] && kill -0 "$(cat /var/run/nginx.pid)" 2>/dev/null; then
    echo "nginx already running."
else
    nginx -g "daemon off;" &
    Nginx_PID=$!
    sleep 1
    if kill -0 $Nginx_PID 2>/dev/null; then
        echo "✓ nginx is PID $Nginx_PID"
    else
        echo "✗ nginx failed to start — falling back to Apache only"
        wait $APACHE_PID
    fi
fi

# Block so the container stays alive
wait $Nginx_PID || wait $APACHE_PID
