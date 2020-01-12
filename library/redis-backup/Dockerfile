ARG VERSION
FROM mikrokosmos/alpine-latest-stable:${VERSION} AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8

COPY redis-backup.sh /

RUN apk update \
    && apk --no-cache add \
        tzdata \
        bash \
        redis \
        rsync \
        nodejs npm \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" >/etc/timezone \
    && npm install -g redis-dump \
    && chmod 500 /redis-backup.sh

FROM base
RUN echo "0-59/5 * * * * /redis-backup.sh" | crontab -
VOLUME ["/data/redis", "/data/backup"]
CMD ["crond", "-f", "-L", "/dev/stdout"]
