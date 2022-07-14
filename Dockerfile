FROM php:8.0-fpm-buster
COPY ./run.sh /opt/run.sh
# COPY ./sources.list /etc/apt/sources.list
LABEL Author="Okami-Chen"
LABEL Version="php-8.x-cli"
LABEL Description="PHP CLI 8.x"
ARG timezone

ENV TIMEZONE=${timezone:-"Asia/Shanghai"} \
    APP_ENV=production \
    LANG=C.UTF-8

RUN ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    && apt-get update -y --fix-missing && apt-get upgrade -y && apt-get -y install --no-install-recommends \
    libfreetype6-dev libjpeg62-turbo-dev libpng-dev autoconf make zlib1g zlib1g-dev \
    libtool wget libxml2-dev bzip2 libsodium-dev libedit-dev libsqlite3-dev libssl-dev \
    libcurl4-openssl-dev libjpeg-dev libpng-dev libxpm-dev libfreetype6-dev libxslt1-dev \
    libbz2-dev bison libffi-dev libzip-dev re2c apt-utils libgtk2.0-dev cmake git \
    unzip supervisor libsnmp-dev libtidy-dev libldap2-dev libc-client-dev libkrb5-dev libicu-dev \
    librabbitmq-dev librabbitmq4 libreadline6-dev \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-install -j$(nproc) ldap \
    && docker-php-ext-install -j$(nproc) dba \
    && docker-php-ext-install -j$(nproc) shmop \
    && docker-php-ext-install -j$(nproc) calendar \
    && docker-php-ext-install -j$(nproc) exif \
    && docker-php-ext-install -j$(nproc) gettext \
    && docker-php-ext-install -j$(nproc) pcntl \
    && docker-php-ext-install -j$(nproc) sysvsem \
    && docker-php-ext-install -j$(nproc) sysvshm \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-install -j$(nproc) mysqli \
    && docker-php-ext-install -j$(nproc) bcmath \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) soap \
    && docker-php-ext-install -j$(nproc) sockets \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-install -j$(nproc) bz2 \
    && cp /usr/bin/clear /usr/bin/cls \
    && cd /tmp \
    && wget https://github.com/swoole/swoole-src/archive/master.tar.gz \
    && tar zxvf master.tar.gz \
    && mv swoole-src* swoole-src && cd swoole-src \
    && phpize && ./configure --enable-openssl --enable-sockets --enable-mysqlnd \
    && make && make install \
    && pecl install redis apcu igbinary \
    && docker-php-ext-enable redis swoole apcu igbinary \
    && php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer \
    && chmod a+x /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man /var/lib/apt/lists/* \
    && apt-get clean && chmod +x /opt/run.sh
