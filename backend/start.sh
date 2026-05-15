#!/bin/bash

# Exit on error
set -e

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
elif [ -n "$FIREBASE_CREDENTIALS_JSON" ]; then
    echo "Found FIREBASE_CREDENTIALS_JSON env var, creating file..."
    mkdir -p storage/app
    echo "$FIREBASE_CREDENTIALS_JSON" > storage/app/firebase-credentials.json
    chmod 644 storage/app/firebase-credentials.json
    export FIREBASE_CREDENTIALS="storage/app/firebase-credentials.json"
    export GOOGLE_APPLICATION_CREDENTIALS="/var/www/html/storage/app/firebase-credentials.json"
fi

# Run migrations (Disabled for Firestore migration)
# php artisan migrate --force

# Force DB connection to sqlite for all artisan commands to bypass PostgreSQL checks
export DB_CONNECTION=sqlite
export DB_DATABASE=:memory:
export DB_HOST=127.0.0.1

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
