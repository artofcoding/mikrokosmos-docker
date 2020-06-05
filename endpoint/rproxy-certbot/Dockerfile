ARG VERSION
FROM mikrokosmos/alpine-latest-stable:${VERSION} AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

RUN apk update \
    && apk --no-cache add \
        openssl \
        certbot-nginx \
        curl

FROM base
COPY nginx-tls.sh /
RUN chmod 500 /nginx-tls.sh \
    && echo "0 0 * * WED,SUN /nginx-tls.sh test renew" | crontab - \
    && echo "0 0 * * WED,SUN /nginx-tls.sh qa renew" | crontab - \
    && echo "0 0 * * WED,SUN /nginx-tls.sh production renew" | crontab -
VOLUME ["/etc/letsencrypt", "/etc/nginx", "/usr/share/nginx/certbot"]
CMD ["crond", "-f", "-L", "/dev/stdout"]
