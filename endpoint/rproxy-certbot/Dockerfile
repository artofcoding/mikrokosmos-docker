ARG VERSION
FROM mikrokosmos/alpine-latest-stable:${VERSION} AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8

COPY nginx-tls.sh /

RUN apk update \
    && apk --no-cache add \
        tzdata \
        openssl \
        certbot-nginx \
        curl \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" >/etc/timezone \
    && chmod 500 /nginx-tls.sh

FROM base
RUN echo "0 0 * * WED,SUN /nginx-tls.sh test renew" | crontab - \
    && echo "0 0 * * WED,SUN /nginx-tls.sh qa renew" | crontab - \
    && echo "0 0 * * WED,SUN /nginx-tls.sh production renew" | crontab -
VOLUME ["/etc/letsencrypt", "/etc/nginx", "/usr/share/nginx/certbot"]
CMD ["crond", "-f", "-L", "/dev/stdout"]
