ARG ENV=development

# Use the official PHP 8.2 FPM Alpine image
FROM php:8.2-fpm-alpine as base

# Install system dependencies required for the PHP extensions
RUN apk add --no-cache \
    postgresql-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libxml2-dev \
    oniguruma-dev \
    zip \
    unzip \
    curl \
    git \
    autoconf \
    g++ \
    make \
    libzip-dev \
    linux-headers \
    fcgi

# Configure and install PHP extensions
# Line by line instead of everything in one line helps for debugging and build caching
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd
RUN docker-php-ext-install pdo_pgsql
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install xml
RUN docker-php-ext-install ctype
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install opcache
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install zip
RUN docker-php-ext-install ftp
RUN docker-php-ext-install exif
RUN docker-php-ext-install sockets

RUN pecl install redis \
    && docker-php-ext-enable redis

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN echo "cp /etc/caddy_data/caddy/pki/authorities/local/root.crt /usr/local/share/ca-certificates/caddy_root.crt && update-ca-certificates" > /setup-certs.sh \
    && chmod +x /setup-certs.sh

# Set the working directory
WORKDIR /var/www

# Set permissions for future mounted volumes
RUN chown -R www-data:www-data /var/www

# Expose port 9000 and start php-fpm server
EXPOSE 9000

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD cgi-fcgi -bind -connect 127.0.0.1:9000 || exit 1

FROM base as development
# development only instructions

CMD sh -c "/setup-certs.sh && php-fpm";

FROM base as preview
# preview only instructions
CMD sh -c "/setup-certs.sh && php-fpm";

FROM base as production

ENV COMPOSER_ALLOW_SUPERUSER=1
ARG BACK_PATH=./src/back

# Copy files and install dependencies if in production mode
COPY $BACK_PATH /var/www
RUN chown -R www-data:www-data /var/www

CMD sh -c "composer install --optimize-autoloader --no-dev && php artisan key:generate && php artisan passport:keys && php-fpm";

# Final stage based on the environment
FROM $ENV as final