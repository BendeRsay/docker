FROM php:8.4-fpm-bullseye

# нужные пакеты
RUN apt-get update && apt-get install -y \
        mc \
        iputils-ping \
        traceroute \
        curl \
        pkg-config \
        nmap \
        htop \
        msmtp \
        git \
        git-lfs

# пакеты для PHP расширений
RUN apt-get update && apt-get install -y \
        libzip-dev \
        libpng-dev \
        libwebp-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libxml2-dev \
        libmemcached-dev \
        && docker-php-ext-install opcache \
        && docker-php-ext-install zip \
        && docker-php-ext-install soap \
        && docker-php-ext-install pdo \
        && docker-php-ext-install pdo_mysql \
        && docker-php-ext-install mysqli \
        && pecl install memcached-3.3.0 && docker-php-ext-enable memcached \
        && pecl install memcache-8.2 && docker-php-ext-enable memcache \
        && pecl install xdebug-3.4.1 && docker-php-ext-enable xdebug \
        && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp; \
        docker-php-ext-install -j$(nproc) gd \
        && apt-get clean && rm -rf /var/lib/apt/lists/*

# Если образ для портала
ARG COMPOSE_PROFILES
RUN if [ "$COMPOSE_PROFILES" = "portal" ]; then \
        apt-get update && apt-get install -y \
        libldap2-dev \
        && docker-php-ext-configure ldap --with-libdir=lib/$(uname -m)-linux-gnu/ \
        && docker-php-ext-install ldap \
        && apt-get clean && rm -rf /var/lib/apt/lists/* ; \
    fi

# Копируем msmtprc конфиг
COPY ./msmtprc /etc/msmtprc

# Добавим свой php.ini, можем в нем определять свои значения конфига
COPY ./php.ini /usr/local/etc/php/conf.d/40-custom.ini

# Куда же без composer'а.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Изменение UID пользователя и работаем под www-data
ENV HOME=/home/www-data
RUN usermod -u 1000 www-data && chown -R www-data:www-data /var/www/html \
        && mkdir -p /home/www-data && chown -R www-data:www-data /home/www-data
USER www-data

CMD ["php-fpm"]
