# alpine
FROM php:7.4-fpm-alpine

# ENV PS1="\u@\h:\w\\$"

RUN apk update \
 && apk add --no-cache $PHPIZE_DEPS \
    bash \
    git \
    zip \
    unzip \
    icu-dev \
    supervisor

# PHP extensions
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl
RUN docker-php-ext-install opcache pdo_mysql mysqli
RUN docker-php-ext-enable opcache
RUN pecl install redis && docker-php-ext-enable redis

RUN apk --update add supervisor

RUN mkdir -p /var/log/supervisor

ADD supervisor.conf /etc/supervisor.d/supervisor.conf


#COPY ./supervisord.conf /etc/supervisor/
#COPY ./config/supervisor/* /etc/supervisor/conf.d/

#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

#

# xdebug extensions
# RUN pecl install xdebug
# RUN docker-php-ext-enable xdebug
#

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer self-update --preview
#

# Composer parallel install plugin
#RUN composer global require hirak/prestissimo
#

RUN rm -rf /var/cache/apk/*

CMD ["php-fpm", "--nodaemonize"]


