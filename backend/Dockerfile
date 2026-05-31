# ==============================================================================
# Build ARGs — override to pin specific versions
# ==============================================================================
ARG PHP_VERSION=8.4
ARG NODE_VERSION=22
ARG COMPOSER_VERSION=2
ARG NGINX_VERSION=

# ==============================================================================
# Stage 1: PHP Extensions (the slow part — cached aggressively)
# ==============================================================================
FROM php:${PHP_VERSION}-apache AS php-base

LABEL org.opencontainers.image.title="SBKU Backend"
LABEL org.opencontainers.image.description="PHP + Nginx production image for sbku backend"
LABEL org.opencontainers.image.source="https://github.com/${GITHUB_REPOSITORY:-sbku/sbku_app}"
LABEL org.opencontainers.image.vendor="SBKU"

# Install system deps + PHP extensions in one layer, clean up immediately
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libonig-dev \
        libxml2-dev \
        libzip-dev \
        libpq-dev \
        zlib1g-dev \
        zip unzip git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_pgsql mbstring bcmath gd zip opcache \
    && pecl install redis \
    && docker-php-ext-enable redis

# gRPC and Protobuf are removed to speed up build time.
# With GOOGLE_CLOUD_USE_REST=true, they are not required for Firestore.

# Enable Apache mod_rewrite, mod_deflate (gzip), mod_expires (cache headers)
RUN a2enmod rewrite deflate expires headers

# PHP JIT is disabled on t3.micro (1 GB RAM) because mod_php/prefork
# allocates JIT buffer per child — 100 MB × 10 children = 1 GB.
# Remove the next two lines on a larger instance to re-enable:
#   echo 'opcache.jit_buffer_size=100M' >> ...
#   echo 'opcache.jit=tracing'          >> ...

# OPcache tuning for low-memory environments
RUN echo 'opcache.memory_consumption=32' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo 'opcache.interned_strings_buffer=8' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo 'opcache.max_accelerated_files=4000' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo 'opcache.revalidate_freq=60' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo 'opcache.fast_shutdown=1' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# Install nginx (used as the production front-end proxy / static-file server)
# Nginx will listen on port 80 and serve:
#   /  → Flutter web build  (/var/www/html/build/web/)
#   /api/*, /dashboard, /login  → Apache/PHP on 127.0.0.1:8080
RUN apt-get update && apt-get install -y --no-install-recommends \
        nginx${NGINX_VERSION:+=${NGINX_VERSION}} \
        openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy nginx config before the build is finalised so the image has it baked in
COPY docker/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /run/php

# ==============================================================================
# Stage 2: Composer (PHP dependencies)
# Runs in parallel with Stage 3 — only re-runs when composer.* changes
# ==============================================================================
FROM composer:${COMPOSER_VERSION} AS vendor
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
FROM node:${NODE_VERSION}-alpine AS assets
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

# ── 1b. Apache & PHP performance config ─────────────────────────────────────
COPY docker/mpm_prefork.conf        /etc/apache2/mods-available/mpm_prefork.conf
COPY docker/php-memory.ini           /usr/local/etc/php/conf.d/php-memory.ini
COPY docker/apache-compress.conf     /etc/apache2/conf-available/apache-compress.conf
COPY docker/apache-performance.conf  /etc/apache2/conf-available/apache-performance.conf
RUN a2enconf apache-compress apache-performance && \
    a2enmod mpm_prefork && \
    echo '' >> /etc/apache2/apache2.conf && \
    echo '# ── MPM prefork limits (t3.micro = 1 GB RAM) ─────────────────' >> /etc/apache2/apache2.conf && \
    echo '<IfModule mpm_prefork_module>' >> /etc/apache2/apache2.conf && \
    echo '    ServerLimit         2' >> /etc/apache2/apache2.conf && \
    echo '    MaxRequestWorkers   2' >> /etc/apache2/apache2.conf && \
    echo '    MaxConnectionsPerChild 500' >> /etc/apache2/apache2.conf && \
    echo '</IfModule>' >> /etc/apache2/apache2.conf

# ── 1c. Flutter web build ─────────────────────────────────────────────────────
# The frontend requires: cd frontend && flutter build web --release
# Content appears at build/web/ and gets COPY'd here.
# If this is empty, the Flutter layer is skipped and start.sh warns.
# Nginx serves it at / from /var/www/html/build/web/
COPY frontend/build/web/ /var/www/html/build/web/

# ── 2. Application source (changes every push — intentionally last) ──────────
COPY . .

# ── 2b. Create .env at build time ───────────────────────────────────────────
# .env is excluded by .dockerignore (secrets). Create a minimal placeholder.
# All secrets (DB creds, APP_KEY, etc.) are injected at runtime via
# ECS task definition environment variables or AWS SSM Parameter Store.
RUN if [ ! -f .env ] && [ -f .env.example ]; then \
        cp .env.example .env && \
        sed -i 's|^APP_URL=.*|APP_URL=http://localhost|' .env && \
        sed -i 's|^DB_CONNECTION=.*|DB_CONNECTION=pgsql|' .env && \
        sed -i 's|^DB_HOST=.*|DB_HOST=localhost|' .env && \
        sed -i 's|^DB_PORT=.*|DB_PORT=5432|' .env && \
        sed -i 's|^DB_DATABASE=.*|DB_DATABASE=neondb|' .env && \
        echo ".env placeholder created at build time (secrets injected at runtime)"; \
    fi

# ── 3. Apache document root → Laravel public/ ────────────────────────────────
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri \
        -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" \
        /etc/apache2/sites-available/*.conf \
        /etc/apache2/apache2.conf \
        /etc/apache2/conf-available/*.conf 2>/dev/null; \
    sed -ri \
        -e "s!DocumentRoot /var/www!DocumentRoot ${APACHE_DOCUMENT_ROOT}!g" \
        /etc/apache2/sites-available/*.conf 2>/dev/null || true

# ── Apache listen port ────────────────────────────────────────────────────────
# Apache is a backend service (behind nginx), so it always listens on 8080.
# Nginx (on port 80) proxies all requests → Apache 8080.
RUN sed -ri \
        -e 's/^Listen .*/Listen 8080/' \
        -e 's/<VirtualHost \*:.*>/<VirtualHost *:8080>/g' \
        /etc/apache2/ports.conf \
        /etc/apache2/sites-available/000-default.conf 2>/dev/null || true

# Validate Apache config and MPM limits after all changes
RUN apachectl configtest 2>&1 || { \
        echo "ERROR: Apache configuration test failed — check Dockerfile settings"; \
        apachectl -S 2>&1 | head -20; \
        exit 1; \
    }
RUN echo "=== Apache MPM configuration ===" && \
    httpd -V 2>&1 | head -20 && \
    echo "--- MPM prefork limits ---" && \
    apachectl -S 2>&1 | grep -i -E "serverlimit|maxrequest|maxclients" || \
    echo "(limits not visible in -S output; checking config file)" && \
    grep -E "ServerLimit|MaxRequestWorkers" /etc/apache2/apache2.conf && \
    echo "=== MPM OK ==="

# Discover package service providers and pre-cache config at build time
# start.sh skips these if files already exist. Best-effort — failures are non-fatal.
RUN rm -f bootstrap/cache/packages.php && \
    php artisan package:discover --ansi 2>/dev/null || true
RUN php artisan config:cache 2>/dev/null || true

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

# HEALTHCHECK: fail fast if nginx isn't responding
# ECS uses this to determine container health for Fargate service auto-recovery.
HEALTHCHECK --interval=15s --timeout=5s --retries=3 --start-period=60s \
  CMD curl -sS "http://localhost/" > /dev/null 2>&1 || curl -sS "http://127.0.0.1:8080/" > /dev/null 2>&1 || exit 1

# ENTRYPOINT: run the runtime startup script (manages nginx + Apache startup)
# start.sh handles all runtime initialization including secret injection.
ENTRYPOINT ["bash", "/var/www/html/start.sh"]

# ECS Fargate uses the containerPort from task definition; EXPOSE is documentary.
EXPOSE 80
EXPOSE 443
EXPOSE 8080
