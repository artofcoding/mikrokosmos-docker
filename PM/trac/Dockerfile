ARG VERSION
FROM mikrokosmos/alpine-latest-stable:${VERSION} AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos PM"

ARG TRAC_VERSION
ARG TRAC_DATA=/var/trac

RUN apk update \
    && apk upgrade \
    && apk add \
        curl \
        git \
        subversion \
        gcc \
        musl-dev \
        secpwgen pwgen \
        py-pip py-setuptools \
        python2-dev \
        postgresql-dev \
        py-genshi \
        graphviz

RUN pip install babel docutils pygments pytz textile \
    && pip install psycopg2 \
    && pip install https://download.edgewall.org/trac/Trac-${TRAC_VERSION}.tar.gz \
    && mkdir ${TRAC_DATA}

VOLUME /var/trac
