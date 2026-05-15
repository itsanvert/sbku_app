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

# gRPC and Protobuf are removed to speed up build time.
# With GOOGLE_CLOUD_USE_REST=true, they are not required for Firestore.

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
# FIX: Copy only frontend-relevant files instead of COPY . .
# This means PHP-only changes no longer bust the npm cache.
# Only re-runs when package.json or actual frontend source changes.
# ==============================================================================
FROM node:20-alpine AS assets
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --prefer-offline

# Copy only what Vite/Mix actually needs — not the entire Laravel app.
# Add or remove lines here to match your project structure.
# Copy only what Vite actually needs
COPY vite.config.js tailwind.config.js postcss.config.js ./
COPY resources/ ./resources/
COPY public/ ./public/

RUN npm run build

# ==============================================================================
# Stage 4: Final production image
# Assembles everything; most layers cached from above stages.
# FIX: Stable artifacts (vendor, assets) are copied BEFORE app source so
# those layers remain cached even when source files change.
# ==============================================================================
FROM php-base AS production

WORKDIR /var/www/html

# Copy composer binary for runtime autoloader optimization
COPY --from=vendor /usr/bin/composer /usr/bin/composer

# ── 1. Stable artifacts first (these layers cache across every push) ──────────
COPY --from=vendor  /app/vendor          ./vendor
COPY --from=assets  /app/public/build    ./public/build

# ── 2. Application source (changes every push — intentionally last) ──────────
COPY . .

# ── 3. Apache document root → Laravel public/ ────────────────────────────────
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

# Make start.sh executable (it handles the remaining runtime setup)
RUN chmod +x /var/www/html/start.sh

# ── Removed from build time (moved to start.sh): ─────────────────────────────
#   composer dump-autoload   — re-ran on every push; ~2 sec saved
#   php artisan storage:link — re-ran on every push; symlink is idempotent
#   chown / chmod storage    — re-ran on every push; applied at runtime instead
# These are all fast and idempotent, so running them at container start
# costs nothing measurable and eliminates unnecessary build-time cache busts.

# Runtime environment
ENV APP_ENV=production \
    APP_DEBUG=false \
    GOOGLE_CLOUD_USE_REST=true

EXPOSE 8080
CMD ["/var/www/html/start.sh"]