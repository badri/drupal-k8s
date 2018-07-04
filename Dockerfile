# Build actual image
FROM php:7.2-apache

WORKDIR /var/www/html

# install packages
RUN apt-get update -y && \
  apt-get install -y \
  curl git openssl \
  less vim wget unzip rsync git mysql-client \
  libcurl4-openssl-dev libfreetype6 libjpeg62-turbo libpng-dev libjpeg-dev libxml2-dev libxpm4 \
  libicu-dev coreutils openssh-client libsqlite3-dev && \
  apt-get clean && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*

# install php extensions
RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/local/ && \
  docker-php-ext-install -j$(nproc) iconv intl pdo_sqlite curl json xml mbstring zip bcmath soap pdo_mysql gd

# apache config
RUN /usr/sbin/a2enmod rewrite && /usr/sbin/a2enmod headers && /usr/sbin/a2enmod expires
COPY ./container/apache.conf /etc/apache2/sites-available/000-default.conf


# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini


COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html/

RUN chmod -R a+w /var/www/html/web/sites/default/files

# composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer install


# Drush
RUN composer require drush/drush;
