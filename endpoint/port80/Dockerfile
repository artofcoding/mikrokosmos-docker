ARG VERSION
FROM mikrokosmos/nginx:${VERSION} AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

COPY port80/nginx.conf /etc/nginx
COPY port80/*.nginx /etc/nginx/conf.d/
