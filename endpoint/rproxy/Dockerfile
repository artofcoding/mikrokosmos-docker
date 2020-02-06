ARG VERSION
FROM mikrokosmos/nginx:${VERSION} AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

COPY rproxy/nginx.conf /etc/nginx
COPY rproxy/enabled/*.nginx /etc/nginx/conf.d/enabled/
COPY rproxy/disabled/*.nginx /etc/nginx/conf.d/disabled/

COPY rproxy/index.html /usr/share/nginx/html
COPY rproxy/robots.txt /usr/share/nginx/html
