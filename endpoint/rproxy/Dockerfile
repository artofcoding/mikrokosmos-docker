ARG VERSION
FROM mikrokosmos/nginx:${VERSION} AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

COPY rproxy/nginx.conf /etc/nginx
COPY rproxy/*.nginx /etc/nginx/conf.d/
COPY pm-cicd/*.nginx /etc/nginx/conf.d/

COPY rproxy/index.html /usr/share/nginx/html
COPY rproxy/robots.txt /usr/share/nginx/html
