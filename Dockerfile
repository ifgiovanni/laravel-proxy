FROM php:8.0.24-apache as build

COPY --from=composer:2.6.5 /usr/bin/composer /usr/bin/composer
WORKDIR /app
RUN apt-get update -y && apt-get -y install git cron zlib1g-dev libpng-dev libzip-dev
RUN docker-php-ext-install mysqli pdo pdo_mysql gd \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip && a2enmod rewrite
COPY database ./database
COPY composer.json ./
RUN composer config -g repo.packagist composer https://repo.packagist.org
RUN composer install --prefer-dist --no-suggest --no-interaction --no-scripts

FROM build as app
EXPOSE 80 443

WORKDIR /app

COPY vhost.conf /etc/apache2/sites-available/000-default.conf
COPY php.ini "$PHP_INI_DIR/php.ini"

COPY --from=build --chown=www-data:www-data /app/vendor/ /app/vendor/
COPY --chown=www-data:www-data . /app
# Clean artisan config cache
RUN php artisan config:cache

# Run the command on container startup
CMD cron && apache2-foreground