FROM php:8.4-apache

LABEL maintainer="selim013@gmail.com" \
    org.opencontainers.image.title="wordpress-apache" \
    org.opencontainers.image.description="WordPress image with Apache, mod_php and wp-cli for PHP 8.4" \
    org.opencontainers.image.vendor="selim13" \
    org.opencontainers.image.source="https://github.com/selim13/docker-wordpress-apache" \
    org.opencontainers.image.url="https://github.com/selim13/docker-wordpress-apache"

ARG WWW_DATA_UID=1000
ARG WWW_DATA_GID=1000

RUN groupmod -o -g "${WWW_DATA_GID}" www-data \
    && usermod -o -u "${WWW_DATA_UID}" -g "${WWW_DATA_GID}" www-data

RUN a2enmod rewrite expires remoteip

# install the PHP extensions we need
RUN apt-get update && apt-get install --no-install-recommends -y \
    msmtp \
    less  \
    mariadb-client  \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libxml2-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/* \
    pecl channel-update pecl.php.net  \
    && MAKEFLAGS="-j $(nproc)" pecl install \
    apcu \
    imagick \
    xdebug \
    && pecl clear-cache \
    && rm -rf /tmp/pear \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    bz2 \
    exif \
    gd \
    gettext \
    intl \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    soap \
    zip \
    && docker-php-ext-enable \
    apcu \
    imagick \
    xdebug

# NOTE: mbstring, pdo, xml are already enabled by default in php:8.4-apache

COPY php/custom.ini /usr/local/etc/php/conf.d/zz-custom.ini
COPY apache2/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN mkdir -p /var/tmp/php/opcache /var/tmp/php/upload /var/tmp/php/session \
    && chown -R www-data:www-data /var/tmp/php \
    && chown www-data:www-data /var/www/html

RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/local/bin --filename=composer

RUN curl -SL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp \
    && mkdir /var/www/.wp-cli \
    && chown www-data:www-data /var/www/.wp-cli

# Apache defaults
ENV APACHE_SERVER_ADMIN=webmaster@localhost \
    APACHE_DOCUMENT_ROOT=/var/www/html

CMD ["apache2-foreground"]
