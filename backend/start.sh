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

# Render persistent disk — create session / cache dirs and set www-data ownership
SESSION_DIR="${SESSION_FILES:-/var/data/sessions}"
CACHE_DIR="${CACHE_FILE_PATH:-/var/data/cache}"
mkdir -p "$SESSION_DIR" "$CACHE_DIR"
chown www-data:www-data "$SESSION_DIR" "$CACHE_DIR"
chmod 775 "$SESSION_DIR" "$CACHE_DIR"

# Fix Firebase permissions on Render
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
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=20000
opcache.revalidate_freq=0
opcache.validate_timestamps=0
opcache.fast_shutdown=1
EOF
    echo "OPcache successfully configured and active."
fi

# Clear caches to ensure fresh production assets
php artisan config:clear
php artisan view:clear
php artisan route:clear
php artisan event:clear

# Discover package service providers (Firebase, Livewire, Flux, etc.)
php artisan package:discover --ansi 2>/dev/null || true

# Cache Laravel configurations, routes, views, and events for maximum production speed
php artisan optimize
php artisan view:cache
php artisan event:cache

# Configure Apache to listen on Render's dynamic PORT
if [ -n "$PORT" ]; then
    # Replace literal ${PORT} (from Dockerfile) or default 80 with the actual runtime port
    sed -i "s/\${PORT}/$PORT/g" /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf || true
    sed -i "s/80/$PORT/g" /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf || true
fi

# Set ServerName globally to suppress Apache qualified domain name warning
echo "ServerName localhost" >> /etc/apache2/apache2.conf || true

# Start Apache
apache2-foreground
