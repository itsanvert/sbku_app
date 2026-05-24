# ==============================================================================
# Stage 1: PHP Extensions (the slow part — cached aggressively)
# ==============================================================================
# Uses a pre-built base so grpc/protobuf are NOT compiled from source.
# This stage is fully cached after the first build as long as
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

# Enable Apache mod_rewrite, mod_deflate (gzip), mod_expires (cache headers)
RUN a2enmod rewrite deflate expires headers

# Install nginx (used as the production front-end proxy / static-file server)
# Nginx will listen on port 80 and serve:
#   /  → Flutter web build  (/var/www/html/build/web/)
#   /api/*, /dashboard, /login  → Apache/PHP on 127.0.0.1:8080
RUN apt-get update && apt-get install -y --no-install-recommends nginx \
    && rm -rf /var/lib/apt/lists/*

# Copy nginx config before the build is finalised so the image has it baked in
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Install PHP-FPM (provides a fastcgi backend if nginx is configured for it)
RUN docker-php-ext-install opcache 2>/dev/null || true \
    && mkdir -p /run/php

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
# Tailwind needs the vendor folder to find classes in packages like Flux
COPY --from=vendor /app/vendor ./vendor

# Copy source files needed for Tailwind class detection
COPY resources/ ./resources/
COPY app/ ./app/
COPY public/ ./public/
COPY vite.config.js tailwind.config.js postcss.config.js ./

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

# ── 1b. Apache MPM prefork config (tuned for throughput) ─────────────────────
COPY docker/mpm_prefork.conf        /etc/apache2/mods-available/mpm_prefork.conf
COPY docker/php-memory.ini           /usr/local/etc/php/conf.d/php-memory.ini
COPY docker/apache-compress.conf     /etc/apache2/conf-available/apache-compress.conf
COPY docker/apache-performance.conf  /etc/apache2/conf-available/apache-performance.conf
RUN a2enconf apache-compress apache-performance

# ── 1c. Flutter web build ─────────────────────────────────────────────────────
# The frontend requires: cd frontend && flutter build web --release
# Content appears at build/web/ and gets COPY'd here.
# If this is empty, the Flutter layer is skipped and the nginx start.sh warns.
# Ensure the build context always contains this path so COPY never fails.
RUN mkdir -p frontend/build/web
COPY frontend/build/web/ /var/www/html/build/web/

# ── 2. Application source (changes every push — intentionally last) ──────────
COPY . .

# ── 2b. Ensure .env exists ──────────────────────────────────────────────────
# .env is excluded by .dockerignore (contains secrets), so copy .env.production
# if no .env is present. Environment variables at runtime override any file.
RUN if [ ! -f .env ]; then cp .env.production .env 2>/dev/null || true; fi

# ── 3. Apache document root → Laravel public/ ────────────────────────────────
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
        /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' \
        /etc/apache2/apache2.conf \
        /etc/apache2/conf-available/*.conf

# ── Apache listen port ────────────────────────────────────────────────────────
# Apache is a backend service (behind nginx), so it always listens on 8080.
# Nginx (on port 80) proxies /api/*, /dashboard, /login → Apache 8080.
RUN sed -ri 's/:80>/:8080>/g' /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf

# Discover package service providers (Firebase, Livewire, Flux, etc.)
# so they are cached even if --no-scripts skipped post-autoload-dump.
# This is best-effort at build time; start.sh re-runs it at runtime.
RUN php artisan package:discover --ansi 2>/dev/null || true

# Pre-compile Blade templates at build time so runtime startup is faster
# (start.sh skips view:cache when the compiled files already exist).
# Best-effort — if it fails (e.g. missing APP_KEY), views compile on demand.
RUN php artisan view:cache 2>/dev/null || true

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
    GOOGLE_CLOUD_USE_REST=true \
    PORT=80

# ENTRYPOINT: run the runtime startup script (navigates nginx + Apache startup, flushes caches)
# start.sh is the only entrypoint; it manages Apache (8080) + nginx (80) internally.
ENTRYPOINT ["sh", "/var/www/html/start.sh"]
EXPOSE 8080
# EXPOSE 80 is implicit (nginx); EXPOSE 8080 (Apache backend) is exposed for diagnostics.

# HEALTHCHECK: fail fast if nginx isn't responding
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=45s \
  CMD curl -fsS "http://localhost/index.html" > /dev/null || exit 1
