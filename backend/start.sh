#!/bin/bash

# Exit on error
set -e

# Create sqlite database if it doesn't exist (if still using it)
if [ "$DB_CONNECTION" = "sqlite" ]; then
    mkdir -p database
    touch database/database.sqlite
fi

# Fix Firebase permissions on Render
if [ -f "/etc/secrets/firebase-credentials.json" ]; then
    echo "Found Firebase credentials in /etc/secrets, preparing for use..."
    mkdir -p storage/app
    cp /etc/secrets/firebase-credentials.json storage/app/firebase-credentials.json
    chmod 644 storage/app/firebase-credentials.json
    # We update the environment variables so Laravel and Google SDK use the readable copy
    export FIREBASE_CREDENTIALS="storage/app/firebase-credentials.json"
    export GOOGLE_APPLICATION_CREDENTIALS="/var/www/html/storage/app/firebase-credentials.json"
fi

# Run migrations (Disabled for Firestore migration)
# php artisan migrate --force

# Force DB connection to sqlite for all artisan commands to bypass PostgreSQL checks
export DB_CONNECTION=sqlite
export DB_DATABASE=:memory:
export DB_HOST=127.0.0.1

# Clear caches to ensure fresh production assets
php artisan config:clear
php artisan view:clear
php artisan route:clear
php artisan optimize

# Start Apache
apache2-foreground
