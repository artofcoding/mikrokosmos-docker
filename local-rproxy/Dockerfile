ARG VERSION
FROM mikrokosmos/nginx:${VERSION} AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

RUN apk --no-cache add \
        certbot-nginx

FROM base
COPY nginx.conf /etc/nginx
COPY enabled/*.nginx /etc/nginx/conf.d/enabled/
COPY disabled/*.nginx /etc/nginx/conf.d/disabled/
VOLUME ["/etc/nginx", "/usr/share/nginx/certbot"]
CMD ["nginx"]
