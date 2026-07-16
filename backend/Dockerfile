# ==============================================================================
# Build ARGs — override to pin specific versions
# ==============================================================================
ARG PHP_VERSION=8.4
ARG NODE_VERSION=22
ARG COMPOSER_VERSION=2

# ==============================================================================
# Stage 1: PHP Extensions (the slow part — cached aggressively)
# ==============================================================================
FROM php:${PHP_VERSION}-apache AS php-base

LABEL org.opencontainers.image.title="SBKU Backend"
LABEL org.opencontainers.image.description="PHP + Apache production image for Render"
LABEL org.opencontainers.image.source="https://github.com/vertsan/sbku_app"
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

# Enable Apache mod_rewrite, mod_deflate (gzip), mod_expires (cache headers)
RUN a2enmod rewrite deflate expires headers

# OPcache tuning for low-memory environments (Render free = 512MB)
RUN echo 'opcache.memory_consumption=24' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo 'opcache.interned_strings_buffer=4' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo 'opcache.max_accelerated_files=2000' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo 'opcache.revalidate_freq=60' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo 'opcache.fast_shutdown=1' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# ==============================================================================
# Stage 2: Composer (PHP dependencies)
# ==============================================================================
FROM composer:${COMPOSER_VERSION} AS vendor
WORKDIR /app
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
# ==============================================================================
FROM node:${NODE_VERSION}-alpine AS assets
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --prefer-offline

COPY --from=vendor /app/vendor ./vendor
COPY resources/ ./resources/
COPY app/ ./app/
COPY public/ ./public/
COPY vite.config.js tailwind.config.js postcss.config.js ./

RUN npm run build

# ==============================================================================
# Stage 4: Final production image
# Apache-only (no nginx) to fit Render free tier 512MB memory limit
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
    a2enmod mpm_prefork

# ── 2. Application source (changes every push — intentionally last) ──────────
COPY . .

# ── 2b. Create .env at build time ───────────────────────────────────────────
RUN if [ ! -f .env ] && [ -f .env.example ]; then \
        cp .env.example .env && \
        sed -i 's|^APP_URL=.*|APP_URL=http://localhost|' .env && \
        sed -i 's|^DB_CONNECTION=.*|DB_CONNECTION=pgsql|' .env && \
        sed -i 's|^DB_HOST=.*|DB_HOST=localhost|' .env && \
        sed -i 's|^DB_PORT=.*|DB_PORT=5432|' .env && \
        sed -i 's|^DB_DATABASE=.*|DB_DATABASE=neondb|' .env && \
        sed -i 's|^DB_USERNAME=.*|DB_USERNAME=|' .env && \
        sed -i 's|^DB_PASSWORD=.*|DB_PASSWORD=|' .env && \
        sed -i '/^DATABASE_URL=/d' .env && \
        sed -i '/^DB_SSLMODE=/d' .env && \
        echo ".env placeholder created at build time (secrets injected at runtime)"; \
    fi

# ── 3. Apache document root → Laravel public/ ────────────────────────────────
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri \
        -e "s!DocumentRoot /var/www/html!DocumentRoot ${APACHE_DOCUMENT_ROOT}!g" \
        -e "s!<Directory /var/www/html!<Directory ${APACHE_DOCUMENT_ROOT}!g" \
        /etc/apache2/sites-available/*.conf \
        /etc/apache2/apache2.conf \
        /etc/apache2/conf-available/*.conf 2>/dev/null || true

# Discover package service providers at build time
RUN rm -f bootstrap/cache/packages.php && \
    php artisan package:discover --ansi 2>/dev/null || true

# Make start.sh executable (it handles the remaining runtime setup)
RUN chmod +x /var/www/html/start.sh

# Runtime environment
ENV APP_ENV=production \
    APP_DEBUG=false \
    GOOGLE_CLOUD_USE_REST=true

# Render uses PORT env var (default 10000). Apache will listen on this port.
ENV PORT=10000

# HEALTHCHECK for Render
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=60s \
  CMD curl -sS "http://localhost:${PORT}/" > /dev/null 2>&1 || exit 1

# Render assigns a PORT env var. start.sh configures Apache to listen on it.
EXPOSE 10000

# ENTRYPOINT: run the runtime startup script
ENTRYPOINT ["bash", "/var/www/html/start.sh"]
