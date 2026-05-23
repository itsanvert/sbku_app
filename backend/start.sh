#!/bin/bash

# Exit on error
set -e

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
    export DATABASE_URL="$NEON_URL"
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
if [ "$USE_FIRESTORE" = "true" ] && [ "$DB_CONNECTION" = "sqlite" ]; then
    echo "USE_FIRESTORE is true with SQLite - skipping database migrations"
    DB_PATH="${DB_DATABASE:-/var/data/database.sqlite}"
    DB_DIR=$(dirname "$DB_PATH")
    mkdir -p "$DB_DIR"
    touch "$DB_PATH"
    echo "Created empty SQLite database at $DB_PATH"
elif [ "$DB_CONNECTION" = "sqlite" ]; then
    php artisan migrate --force --database=sqlite
else
    php artisan migrate --force
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
php artisan optimize

# Compile Blade templates only if not already cached (saves ~7s on restarts when
# the view cache was pre-built at Docker build time or persisted across restarts).
if [ -z "$(find storage/framework/views/ -maxdepth 1 -name '*.php' 2>/dev/null | head -1)" ]; then
    php artisan view:cache
fi

# Re-apply storage ownership because php artisan optimize may create new files as root
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Configure Apache to listen on the runtime port ($PORT env var or default 80)
LISTEN_PORT="${PORT:-80}"
sed -i "s/\${PORT}/$LISTEN_PORT/g" /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf || true
sed -i "s/80/$LISTEN_PORT/g" /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf || true

# Set ServerName globally to suppress Apache qualified domain name warning
# UseCanonicalName Off ensures PHP uses the real Host header, not ServerName
echo "ServerName _default_" >> /etc/apache2/apache2.conf || true
echo "UseCanonicalName Off" >> /etc/apache2/apache2.conf || true

# Start queue worker in the background (skip if WEB_ONLY is set)
if [ -z "$WEB_ONLY" ]; then
    php artisan queue:work --queue=default --sleep=3 --tries=3 --max-time=3600 &
    echo "Queue worker started."
else
    echo "WEB_ONLY set — skipping queue worker."
fi

# Start Apache
apache2-foreground
