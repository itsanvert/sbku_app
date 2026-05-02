#!/bin/bash

# Exit on error
set -e

# Create sqlite database if it doesn't exist (if still using it)
if [ "$DB_CONNECTION" = "sqlite" ]; then
    mkdir -p database
    touch database/database.sqlite
fi

# Run migrations
php artisan migrate --force

# Clear caches to ensure fresh production assets
php artisan config:clear
php artisan view:clear
php artisan route:clear
php artisan optimize

# Start Apache
apache2-foreground
