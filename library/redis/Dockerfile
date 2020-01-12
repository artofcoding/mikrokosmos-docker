FROM redis:5.0-alpine AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8

RUN apk update \
    && apk --no-cache add \
        tzdata \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" >/etc/timezone

FROM base
COPY redis.conf /usr/local/etc/redis/redis.conf
EXPOSE 6379
VOLUME ["/data/redis"]
CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
