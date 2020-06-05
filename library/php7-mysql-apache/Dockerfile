FROM php:7.3-apache

RUN apt-get -y update \
    && apt-get -y install locales libgd3 libjpeg62-turbo libjpeg62-turbo-dev libpng-dev \
    && locale-gen

RUN docker-php-ext-install mysqli \
    && docker-php-ext-enable mysqli

RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/lib/x86_64-linux-gnu \
    && docker-php-ext-install gd \
    && docker-php-ext-enable gd

RUN a2enmod rewrite
