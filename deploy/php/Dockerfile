FROM php:7.2-fpm

RUN apt-get update \
    && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev

RUN  docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
     && docker-php-ext-install gd \
     && :\
     && docker-php-ext-install pdo pdo_mysql opcache \
     && docker-php-ext-enable pdo pdo_mysql opcache
