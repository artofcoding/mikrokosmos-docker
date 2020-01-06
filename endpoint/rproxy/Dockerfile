ARG VERSION
FROM nginx:1.17-alpine AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8

RUN apk update \
    && apk --no-cache add \
        tzdata \
        curl \
        git \
        nginx nginx-mod-http-headers-more \
        openssl \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" >/etc/timezone \
    && rm /etc/nginx/conf.d/default.conf* \
    && adduser -u 82 -D -S -G www-data www-data \
    && git clone https://github.com/h5bp/server-configs-nginx.git /etc/nginx/h5bp \
    && apk del git

FROM base
ARG ENV_TYPE=development
COPY nginx.conf /etc/nginx
COPY rproxy-*.nginx /etc/nginx/conf.d/
COPY index.html /usr/share/nginx/html
COPY robots.txt /usr/share/nginx/html
RUN sed -i'' -E \
    -e "s/#(include \/etc\/nginx\/conf.d\/rproxy-${ENV_TYPE}.nginx)/\1/" \
    /etc/nginx/nginx.conf
VOLUME ["/etc/letsencrypt", "/etc/nginx", "/usr/share/nginx/html"]
CMD ["nginx"]
