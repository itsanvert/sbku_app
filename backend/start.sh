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

# Fix Firebase permissions on Render
if [ -f "/etc/secrets/firebase-credentials.json" ]; then
    echo "Found Firebase credentials in /etc/secrets, preparing for use..."
    mkdir -p storage/app
    cp /etc/secrets/firebase-credentials.json storage/app/firebase-credentials.json
    chmod 644 storage/app/firebase-credentials.json
    export FIREBASE_CREDENTIALS="storage/app/firebase-credentials.json"
    export GOOGLE_APPLICATION_CREDENTIALS="/var/www/html/storage/app/firebase-credentials.json"
    export USE_FIRESTORE="true"
    export DB_CONNECTION="sqlite"
elif [ -n "$FIREBASE_CREDENTIALS_JSON" ]; then
    echo "Found FIREBASE_CREDENTIALS_JSON env var, creating file..."
    mkdir -p storage/app
    echo "$FIREBASE_CREDENTIALS_JSON" > storage/app/firebase-credentials.json
    chmod 644 storage/app/firebase-credentials.json
    export FIREBASE_CREDENTIALS="storage/app/firebase-credentials.json"
    export GOOGLE_APPLICATION_CREDENTIALS="/var/www/html/storage/app/firebase-credentials.json"
    export USE_FIRESTORE="true"
    export DB_CONNECTION="sqlite"
fi

# Run migrations (skip if using Firestore)
if [ "$USE_FIRESTORE" = "true" ]; then
    echo "USE_FIRESTORE is true - skipping database migrations"
    # Create empty SQLite database to prevent connection errors
    mkdir -p database
    touch database/database.sqlite
elif [ "$DB_CONNECTION" = "sqlite" ]; then
    php artisan migrate --force --database=sqlite
else
    php artisan migrate --force
fi

# Public storage symlink for profile images (idempotent)
php artisan storage:link --force 2>/dev/null || php artisan storage:link 2>/dev/null || true

# Clear caches to ensure fresh production assets
php artisan config:clear
php artisan view:clear
php artisan route:clear
php artisan optimize

# Configure Apache to listen on Render's dynamic PORT
if [ -n "$PORT" ]; then
    # Replace literal ${PORT} (from Dockerfile) or default 80 with the actual runtime port
    sed -i "s/\${PORT}/$PORT/g" /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf || true
    sed -i "s/80/$PORT/g" /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf || true
fi

# Start Apache
apache2-foreground
