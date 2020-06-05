FROM nginx:1.17-alpine AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8

RUN apk update \
    && apk --no-cache add \
        tzdata \
        nginx nginx-mod-http-headers-more \
        openssl \
        curl \
        git \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" >/etc/timezone \
    && rm /etc/nginx/conf.d/default.conf* \
    && adduser -u 82 -D -S -G www-data www-data \
    && git clone https://github.com/h5bp/server-configs-nginx.git /etc/nginx/h5bp \
    && apk del git

VOLUME ["/etc/nginx"]
CMD ["nginx"]
