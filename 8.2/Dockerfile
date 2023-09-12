FROM php:8.2-apache

LABEL maintainer="selim013@gmail.com"

RUN a2enmod rewrite expires remoteip

# install the PHP extensions we need
RUN apt-get update && apt-get install --no-install-recommends -y msmtp less mariadb-client libfreetype6-dev libpng-dev libwebp-dev libjpeg-dev libmagickwand-dev libzip-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j "$(nproc)" bcmath exif gd mysqli opcache zip

RUN pecl install imagick-3.7.0 \
    && docker-php-ext-enable imagick

COPY php/opcache-recomended.ini /usr/local/etc/php/conf.d/
COPY php/msmtp.ini /usr/local/etc/php/conf.d/
COPY php/upload.ini /usr/local/etc/php/conf.d/
COPY php/mysql.ini /usr/local/etc/php/conf.d/
COPY apache2/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN mkdir -p /tmp/opcache \
    && chown -R www-data:www-data /tmp/opcache \
    && chown www-data:www-data /var/www/html

### WP-CLI
RUN curl -SL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

# Apache defaults
ENV APACHE_SERVER_ADMIN=webmaster@localhost \
    APACHE_DOCUMENT_ROOT=/var/www/html

CMD ["apache2-foreground"]
