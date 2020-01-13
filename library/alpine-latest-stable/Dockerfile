FROM alpine:3.11 AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY alpine-upgrade.sh /
COPY repositories /etc/apk/repositories

RUN apk update \
    && apk upgrade --available \
    && apk --no-cache add \
        tzdata \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" >/etc/timezone \
    && echo "0 0 * * SAT /alpine-upgrade.sh" | crontab -

FROM base
CMD ["crond", "-f", "-L", "/dev/stdout"]
