#!/bin/bash

# ── Logging helpers ─────────────────────────────────────────────────────
log()   { echo "[$(date -Iseconds)] $*"; }
warn()  { echo "[$(date -Iseconds)] WARNING: $*" >&2; }
error() { echo "[$(date -Iseconds)] ERROR: $*" >&2; }

# IMPORTANT: Do NOT use `set -e`. A failure in any one step (migration,
# config cache, etc.) should NOT kill the whole container. We handle
# errors explicitly so Apache always gets a chance to start.

# ── Graceful shutdown trap ───────────────────────────────────────────────
cleanup() {
    local signal=$1
    log "Received $signal — shutting down gracefully..."
    if [ -n "$WATCHDOG_PID" ] && kill -0 "$WATCHDOG_PID" 2>/dev/null; then
        kill -TERM "$WATCHDOG_PID" 2>/dev/null || true
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
    sed -i '/^APP_KEY=/d' /var/www/html/.env 2>/dev/null || true
    NEW_KEY=$(php /var/www/html/artisan key:generate --show 2>/dev/null || echo "")
    if [ -n "$NEW_KEY" ]; then
        echo "APP_KEY=$NEW_KEY" >> /var/www/html/.env
        log "APP_KEY generated successfully."
    else
        error "Failed to generate APP_KEY — continuing anyway"
    fi
fi

# ── Write env vars into .env ──────────────────────────────────────────
write_env() {
    local key="$1"
    local val="$2"
    if [ -n "$val" ]; then
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
    log "NEON_DATABASE_URL provided"
fi

if [ -n "$DATABASE_URL" ]; then
    write_env "DATABASE_URL" "$DATABASE_URL"
fi

# ── Neon (serverless Postgres) auto-parsing ──────────────────────────
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

# PostgreSQL keepalive
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
chown -R www-data:www-data storage bootstrap/cache 2>/dev/null || true
chmod -R 775 storage bootstrap/cache 2>/dev/null || true

SESSION_DIR="${SESSION_FILES:-/var/data/sessions}"
CACHE_DIR="${CACHE_FILE_PATH:-/var/data/cache}"
mkdir -p "$SESSION_DIR" "$CACHE_DIR"
chown www-data:www-data "$SESSION_DIR" "$CACHE_DIR" 2>/dev/null || true
chmod 775 "$SESSION_DIR" "$CACHE_DIR" 2>/dev/null || true

# ── Firebase credentials ────────────────────────────────────────────────
if [ -f "/etc/secrets/firebase-credentials.json" ]; then
    log "Found Firebase credentials in /etc/secrets"
    mkdir -p storage/app
    cp /etc/secrets/firebase-credentials.json storage/app/firebase-credentials.json
    chmod 644 storage/app/firebase-credentials.json
    export FIREBASE_CREDENTIALS="storage/app/firebase-credentials.json"
    export GOOGLE_APPLICATION_CREDENTIALS="/var/www/html/storage/app/firebase-credentials.json"
    [ -z "$USE_FIRESTORE" ] && export USE_FIRESTORE="true"
elif [ -n "$FIREBASE_CREDENTIALS_JSON" ]; then
    log "Found FIREBASE_CREDENTIALS_JSON env var"
    mkdir -p storage/app
    echo "$FIREBASE_CREDENTIALS_JSON" > storage/app/firebase-credentials.json
    chmod 644 storage/app/firebase-credentials.json
    export FIREBASE_CREDENTIALS="storage/app/firebase-credentials.json"
    export GOOGLE_APPLICATION_CREDENTIALS="/var/www/html/storage/app/firebase-credentials.json"
    [ -z "$USE_FIRESTORE" ] && export USE_FIRESTORE="true"
fi

# ── Redis (if REDIS_HOST is set, configure .env for redis cache/session) ────
if [ -n "$REDIS_HOST" ]; then
    log "Redis host detected — enabling redis cache and session driver..."
    write_env "CACHE_STORE" "redis"
    write_env "SESSION_DRIVER" "redis"
    write_env "REDIS_HOST" "$REDIS_HOST"
    write_env "REDIS_PASSWORD" "${REDIS_PASSWORD:-}"
    write_env "REDIS_PORT" "${REDIS_PORT:-6379}"
fi

# ── Laravel initialization (best-effort — don't block Apache on failure) ──
log "Running Laravel setup (best-effort)..."

php artisan storage:link --force 2>/dev/null || php artisan storage:link 2>/dev/null || true

# Apply pending migrations (idempotent — no-op if nothing pending).
timeout 30 php artisan migrate --force 2>&1 || warn "Migration failed (tables may be stale)"

rm -f bootstrap/cache/packages.php
php artisan package:discover --ansi 2>/dev/null || true

# ── Regenerate config/route/event cache at runtime ──────────────────────────
log "Regenerating config, route, and view caches with runtime environment..."
rm -f bootstrap/cache/config.php bootstrap/cache/routes-v7.php bootstrap/cache/events.php
php artisan optimize 2>/dev/null || warn "Optimize failed (config/route/event cache skipped)"

log "Caching views..."
rm -rf storage/framework/views/*.php
php artisan view:cache 2>/dev/null || warn "View cache failed (templates compile on demand)"

chown -R www-data:www-data storage bootstrap/cache 2>/dev/null || true
chmod -R 775 storage bootstrap/cache 2>/dev/null || true

# ── 502 error page ────────────────────────────────────────────────────
cat > /var/www/html/public/502.html << 'ERR502'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>502 Bad Gateway</title>
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body { font-family:-apple-system,sans-serif; display:flex; align-items:center; justify-content:center; min-height:100vh; background:#fef2f2; }
.container { text-align:center; padding:2rem; max-width:480px; }
h1 { font-size:2.5rem; color:#dc2626; margin-bottom:0.5rem; }
p { color:#666; line-height:1.5; margin-bottom:0.5rem; }
.hint { font-size:0.85rem; color:#999; margin-top:1.5rem; }
</style>
</head>
<body>
<div class="container">
<h1>502</h1>
<p>The backend server is starting up.</p>
<p>Please wait a moment and refresh.</p>
<div class="hint">Free instances spin down after inactivity and may take up to 50 seconds to respond.</div>
</div>
</body>
</html>
ERR502
log "502 error page created at /var/www/html/public/502.html"

# ── Queue worker (disabled by default on free tier to save memory) ─────
if [ "${ENABLE_QUEUE:-false}" = "true" ]; then
    php artisan queue:work --queue=default --sleep=3 --tries=3 --max-time=3600 &
    QUEUE_PID=$!
    log "Queue worker started (PID $QUEUE_PID)."
else
    log "ENABLE_QUEUE not set — skipping queue worker (saves ~50 MB RAM)."
fi

# ══════════════════════════════════════════════════════════════════════════
# Process watchdog — restarts Apache if it dies
# ══════════════════════════════════════════════════════════════════════════
watchdog() {
    while true; do
        sleep 30

        # Check Apache
        if [ -n "$APACHE_PID" ] && ! kill -0 "$APACHE_PID" 2>/dev/null; then
            warn "Apache (PID $APACHE_PID) died — restarting..."
            apache2-foreground &
            APACHE_PID=$!
            log "Apache restarted (new PID $APACHE_PID)"
        fi
    done
}

watchdog &
WATCHDOG_PID=$!
log "Process watchdog started (PID $WATCHDOG_PID)"

# ══════════════════════════════════════════════════════════════════════════
# Apache startup (Render assigns PORT via environment variable)
# ══════════════════════════════════════════════════════════════════════════

# Render provides PORT env var (default 10000)
APACHE_PORT="${PORT:-10000}"
log "Render PORT=$APACHE_PORT"

# ── 1. Validate Apache config ──────────────────────────────────────────
log "Validating Apache configuration..."
if ! apachectl configtest 2>&1; then
    error "Apache configuration is INVALID — fix the config and rebuild."
fi

# ── 2. Configure Apache to listen on Render's PORT ─────────────────────
APACHE_PORTS="/etc/apache2/ports.conf"
APACHE_SITE="/etc/apache2/sites-available/000-default.conf"

log "Configuring Apache to listen on port $APACHE_PORT..."
sed -i '/^Listen /d' "$APACHE_PORTS" 2>/dev/null || true
echo "Listen $APACHE_PORT" >> "$APACHE_PORTS"
sed -i "s/:[0-9]\+>/:${APACHE_PORT}>/g" "$APACHE_SITE" 2>/dev/null || true
echo "ServerName _default_" >> /etc/apache2/apache2.conf 2>/dev/null || true
echo "UseCanonicalName Off" >> /etc/apache2/apache2.conf 2>/dev/null || true

# ── 3. Start Apache on Render's PORT ──────────────────────────────────
log "Starting Apache on port $APACHE_PORT..."
apache2-foreground &
APACHE_PID=$!

# Wait for Apache to start listening (up to 30s, polling every 3s)
APACHE_READY=false
for i in $(seq 1 10); do
    if command -v ss &> /dev/null; then
        if ss -tlnp 2>/dev/null | grep -q ":${APACHE_PORT}"; then
            log "Apache listening on port $APACHE_PORT"; APACHE_READY=true; break
        fi
    elif command -v netstat &> /dev/null; then
        if netstat -tlnp 2>/dev/null | grep -q ":${APACHE_PORT}"; then
            log "Apache listening on port $APACHE_PORT"; APACHE_READY=true; break
        fi
    fi
    if ! kill -0 "$APACHE_PID" 2>/dev/null; then
        error "Apache process (PID $APACHE_PID) died prematurely!"
        error "Check logs: cat /var/log/apache2/error.log"
        break
    fi
    sleep 3
done

# Verify Apache responds to HTTP
if [ "$APACHE_READY" = true ] && command -v curl &> /dev/null; then
    for i in 1 2 3; do
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${APACHE_PORT}/" 2>/dev/null || echo "000")
        if [ "$HTTP_CODE" != "000" ]; then
            log "Apache reachable on port $APACHE_PORT (HTTP $HTTP_CODE)"
            break
        fi
        [ "$i" -eq 3 ] && warn "Apache unreachable on port $APACHE_PORT after 3 curl attempts"
        sleep 2
    done
fi

if [ "$APACHE_READY" = false ]; then
    error "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    error "Apache is NOT running on port $APACHE_PORT."
    error "Check Apache error log:  cat /var/log/apache2/error.log"
    error "Check Apache access log: cat /var/log/apache2/access.log"
    error "Check Laravel log:       cat storage/logs/laravel.log"
    error "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

log "SBKU backend is operational on port $APACHE_PORT."

# Block so the container stays alive (handles signals via trap)
wait $APACHE_PID 2>/dev/null || wait $WATCHDOG_PID
