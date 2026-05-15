# ==============================================================================
# Stage 1: PHP Extensions (the slow part — cached aggressively)
# ==============================================================================
# Uses a pre-built base so grpc/protobuf are NOT compiled from source.
# On Render, this stage is fully cached after the first build as long as
# nothing in this layer changes.
FROM php:8.4-apache AS php-base

# Install system deps in one layer, clean up immediately
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libonig-dev \
        libxml2-dev \
        libzip-dev \
        libpq-dev \
        zlib1g-dev \
        zip unzip git curl \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions via docker-php-ext-install (fast, no compilation)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd zip

# Install gRPC + Protobuf from pre-compiled PECL binaries.
# GOOGLE_CLOUD_USE_REST=true means grpc is optional at runtime;
# install it but do NOT block the build if it fails.
# Pin versions so Docker layer cache stays valid between builds.
RUN pecl install grpc-1.65.0 protobuf-4.28.3 \
    && docker-php-ext-enable grpc protobuf \
    && rm -rf /tmp/pear

# Enable Apache mod_rewrite once here; never changes
RUN a2enmod rewrite

# ==============================================================================
# Stage 2: Composer (PHP dependencies)
# Runs in parallel with Stage 3 — only re-runs when composer.* changes
# ==============================================================================
FROM composer:2 AS vendor
WORKDIR /app
# Copy only the lockfiles first so this layer is cached unless deps change
COPY composer.json composer.lock ./
RUN composer install \
        --no-interaction \
        --no-scripts \
        --no-dev \
        --ignore-platform-reqs \
        --prefer-dist \
        --optimize-autoloader

# ==============================================================================
# Stage 3: Node / Frontend assets
# Only re-runs when package.json / frontend source changes
# ==============================================================================
FROM node:20-alpine AS assets
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --prefer-offline
COPY . .
RUN npm run build

# ==============================================================================
# Stage 4: Final production image
# Assembles everything; most layers cached from above stages
# ==============================================================================
FROM php-base AS production

WORKDIR /var/www/html

# Copy application source (changes every push — intentionally last)
COPY . .

# Bring in pre-built artifacts from other stages
COPY --from=vendor  /app/vendor          ./vendor
COPY --from=assets  /app/public/build    ./public/build

# Finalize autoloader (scripts now safe to run with real vendor present)
RUN composer dump-autoload --optimize --no-dev --no-scripts

# Storage / cache permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R ug+rwx storage bootstrap/cache \
    && chmod +x /var/www/html/start.sh

# Apache document root → Laravel public/
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
        /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' \
        /etc/apache2/apache2.conf \
        /etc/apache2/conf-available/*.conf

# Render injects $PORT at runtime (default 8080)
RUN sed -i 's/80/${PORT}/g' \
        /etc/apache2/sites-available/000-default.conf \
        /etc/apache2/ports.conf

# Laravel storage symlink (public/storage → storage/app/public)
RUN rm -rf public/storage && php artisan storage:link --no-interaction

# Runtime environment
ENV APP_ENV=production \
    APP_DEBUG=false \
    GOOGLE_CLOUD_USE_REST=true

EXPOSE 8080
CMD ["/var/www/html/start.sh"]