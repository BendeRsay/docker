FROM php:7.2-fpm-bullseye

# нужные пакеты
RUN apt-get update && apt-get install -y \
        mc \
        iputils-ping \
        traceroute \
        curl \
        pkg-config \
        nmap \
        htop \
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
        && pecl install memcached-3.1.5 && docker-php-ext-enable memcached \
        && pecl install memcache-4.0.5.2 && docker-php-ext-enable memcache \
        && pecl install xdebug-3.1.6 && docker-php-ext-enable xdebug \
        && docker-php-ext-configure gd --with-gd --with-freetype-dir --with-jpeg-dir  --with-png-dir --with-webp-dir; \
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

# Настройки почтовика
RUN if [ $(uname -m) = "x86_64" ]; then \
        curl -Lsf 'https://storage.googleapis.com/golang/go1.17.4.linux-amd64.tar.gz' | tar -C '/usr/local' -xvzf -; \
    else \
        curl -Lsf 'https://storage.googleapis.com/golang/go1.17.4.linux-arm64.tar.gz' | tar -C '/usr/local' -xvzf -; \
    fi
ENV PATH /usr/local/go/bin:$PATH
RUN go get github.com/mailhog/mhsendmail && cp /root/go/bin/mhsendmail /usr/bin/mhsendmail

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
