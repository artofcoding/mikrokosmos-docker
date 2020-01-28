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
        py-pip py-setuptools \
        gcc \
        musl-dev \
        python2-dev \
        postgresql-dev \
        secpwgen pwgen \
        graphviz

RUN pip install babel docutils pygments pytz textile \
    && pip install psycopg2 \
    && pip install Trac \
    && mkdir ${TRAC_DATA}

# AgiloForTrac
# http://www.agilofortrac.com/documentation/installation-guide/
ARG AGILO_VERSION="0.9.15"
ARG AGILO_DIST="agilo-source-${AGILO_VERSION}-tar.gz"
RUN curl -L \
        -o "${TRAC_DATA}/${AGILO_DIST}" \
        http://www.agilofortrac.com/download/${AGILO_DIST} \
    && tar -C ${TRAC_DATA} -xzf "${TRAC_DATA}/${AGILO_DIST}" \
    && cd "${TRAC_DATA}/agilo-${AGILO_VERSION}" >/dev/null \
    && python setup.py install \
    && cd .. \
    && trac-admin "${TRAC_DATA}"/MyProject upgrade --no-backup \
    && trac-admin "${TRAC_DATA}"/MyProject wiki upgrade

VOLUME /var/trac
