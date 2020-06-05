ARG VERSION
FROM mikrokosmos/alpine-latest-stable:${VERSION}

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

RUN apk update \
    && apk --no-cache add \
        tzdata \
        openjdk11-jre-headless \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" >/etc/timezone \
