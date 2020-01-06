ARG VERSION
FROM mikrokosmos/alpine-latest-stable:${VERSION} AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos PM"

ARG TRAC_DATA=/var/trac

RUN apk update \
    && apk upgrade \
    && apk add \
        curl \
        git \
        subversion \
        py-pip \
        gcc \
        musl-dev \
        python2-dev \
        postgresql-dev \
    && pip install babel docutils pygments pytz textile \
    && pip install psycopg2 \
    && pip install Trac \
    && mkdir ${TRAC_DATA}

RUN pip install trac-UserPicturesPlugin

RUN curl -sL \
        -o ${TRAC_DATA}/trac-digest.py \
        http://www.agilofortrac.com/en/download/trac-digest.py

VOLUME /var/trac
