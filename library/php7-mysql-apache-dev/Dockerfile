ARG VERSION
FROM mikrokosmos/php7-mysql-apache:${VERSION}

RUN pecl install xdebug-2.7.0 \
    && docker-php-ext-enable xdebug
