#!/bin/bash
set -e

# ==============================================================================
# Runtime startup script
# ==============================================================================
# Steps previously done at Docker build time are now here because they ran
# AFTER "COPY . ." and therefore busted the layer cache on every single push.
# Running them at container start costs ~2–3 seconds and is fully equivalent.

# ------------------------------------------------------------------------------
# 1. SQLite database (only when DB_CONNECTION=sqlite)
# ------------------------------------------------------------------------------
if [ "$DB_CONNECTION" = "sqlite" ]; then
    mkdir -p database
    touch database/database.sqlite
fi

# ------------------------------------------------------------------------------
# 2. Firebase credentials
#    Priority: mounted secret file > env var JSON blob
# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
# 3. Force SQLite in-memory for all artisan commands
#    (bypasses PostgreSQL/Firestore connectivity checks at boot time)
# ------------------------------------------------------------------------------
export DB_CONNECTION=sqlite
export DB_DATABASE=:memory:
export DB_HOST=127.0.0.1

# ------------------------------------------------------------------------------
# 4. Autoloader + storage symlink + permissions
#    (moved from Dockerfile build time to avoid cache-busting on every push)
# ------------------------------------------------------------------------------
composer dump-autoload --optimize --no-dev --no-scripts --quiet

php artisan storage:link --no-interaction --quiet || true

chown -R www-data:www-data storage bootstrap/cache
chmod -R ug+rwx storage bootstrap/cache

# ------------------------------------------------------------------------------
# 5. Clear and warm Laravel caches
# ------------------------------------------------------------------------------
php artisan config:clear
php artisan view:clear
php artisan route:clear
php artisan optimize

# ------------------------------------------------------------------------------
# 6. Apache port binding (Render injects $PORT at runtime)
#    The Dockerfile already baked in ${PORT} as a literal placeholder;
#    this resolves it to the actual value at startup.
#    Both sed passes are safe with || true — one will always be a no-op.
# ------------------------------------------------------------------------------
if [ -n "$PORT" ]; then
    sed -i "s/\${PORT}/$PORT/g" \
        /etc/apache2/sites-available/000-default.conf \
        /etc/apache2/ports.conf || true
    sed -i "s/80/$PORT/g" \
        /etc/apache2/sites-available/000-default.conf \
        /etc/apache2/ports.conf || true
fi

# ------------------------------------------------------------------------------
# 7. Optional: run migrations on every deploy
#    Uncomment if you want automatic migration at startup.
# ------------------------------------------------------------------------------
# php artisan migrate --force --no-interaction --quiet

# ------------------------------------------------------------------------------
# 8. Hand off to Apache
# ------------------------------------------------------------------------------
exec apache2-foreground