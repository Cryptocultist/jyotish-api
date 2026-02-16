# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER=1

# Set working directory
WORKDIR /var/www/api

# Install system dependencies
RUN apt-get update -y && \
    apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    libpng-dev \
    curl \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    g++ \
    make \
    nginx

# Add PHP repository
RUN add-apt-repository ppa:ondrej/php -y

# Update package list after adding new repository
RUN apt-get update -y

# Install PHP and required extensions
RUN apt-get install -y \
    php7.4 \
    php7.4-fpm \
    php7.4-cli \
    php7.4-common \
    php7.4-mysql \
    php7.4-xml \
    php7.4-mbstring \
    php7.4-curl \
    php7.4-zip \
    php7.4-gd \
    php7.4-intl \
    php7.4-bcmath \
    php7.4-soap \
    php7.4-opcache

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Clean up after installation
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy composer.json and composer.lock
COPY composer.json ./

# Install composer dependencies
RUN set -eux; \
    composer install --verbose --no-interaction; \
    composer clear-cache

# Copy rest of the application
COPY . .

# After copying application files but before clearing cache
RUN mkdir -p /var/www/api/var/cache /var/www/api/var/log && \
    chown -R www-data:www-data /var/www/api/var && \
    chmod -R 777 /var/www/api/var

# Run composer dump-autoload optimizing for production
RUN set -eux; \
    composer dump-autoload --optimize;

# Compile Swiss Ephemeris (required for Jyotish calculations)
RUN cd swetest/src && make clean && make && \
    chmod 755 /var/www/api/swetest/src && chmod +x /var/www/api/swetest/src/swetest

# Configure Nginx to listen on port 9393
COPY nginx.conf /etc/nginx/sites-available/default

# Configure PHP-FPM logging
RUN sed -i 's/;error_log = php_errors.log/error_log = \/var\/log\/php7.4-fpm.log/' /etc/php/7.4/fpm/php-fpm.conf

# Create log directories and set permissions
RUN mkdir -p /var/log/nginx /var/log/php7.4-fpm && \
    chown -R www-data:www-data /var/log/nginx /var/log/php7.4-fpm

# Install Symfony assets
RUN php bin/console assets:install --symlink

# Clear Symfony cache
RUN php bin/console cache:clear

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose port 9393
EXPOSE 9393

# Start PHP-FPM and Nginx via startup script
CMD ["/start.sh"]