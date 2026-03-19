# ============================================================================
# CSWeb Community Platform - Production Dockerfile
# ============================================================================
# Author: Bouna DRAME
# Date: 14 Mars 2026
# Version: 1.0.0
#
# Multi-stage build for optimized production image
# ============================================================================

FROM php:8.1-apache AS base

# Install system dependencies for ALL database drivers
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    unzip \
    unixodbc-dev \
    gnupg2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Microsoft ODBC Driver for SQL Server (compatible Debian 13+)
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl -fsSL https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list \
    && sed -i 's|signed-by=/usr/share/keyrings/microsoft-prod.gpg||g; s|arch=amd64,arm64,armhf ||g' /etc/apt/sources.list.d/mssql-release.list || true \
    && echo "deb [signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 || true \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions for MySQL and PostgreSQL
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    mysqli \
    pgsql \
    mbstring \
    xml \
    zip \
    opcache

# Install PHP extensions for SQL Server
RUN pecl install sqlsrv-5.11.1 pdo_sqlsrv-5.11.1 \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv

# Enable Apache modules
RUN a2enmod rewrite headers ssl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html

# Install PHP dependencies (--no-scripts car config.php est genere via /setup)
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Set base permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && mkdir -p /var/www/html/files \
    && mkdir -p /var/www/html/var/cache \
    && mkdir -p /var/www/html/var/logs \
    && chmod -R 775 /var/www/html/files \
    && chmod -R 777 /var/www/html/var

# Copy and set entrypoint (auto: permissions, cache clear)
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost/api/ || exit 1

# Entrypoint handles permissions + cache, then starts Apache
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
