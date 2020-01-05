FROM mikrokosmos/alpine-latest-stable:latest AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

ARG REPO=https://github.com/artofcoding/asciidocserver.git
ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8

WORKDIR /opt/asciidocserver

RUN apk --no-cache add \
        git \
        nodejs \
        npm \
        asciidoc asciidoctor \
    && gem install rdoc --no-document \
    && gem install prawn --version 2.1.0 \
    && gem install prawn-svg --version 0.26.0 \
    && gem install prawn-templates --version 0.0.4 \
    && gem update asciidoctor \
    && git clone ${REPO} .

COPY asciidocserver.sh .

RUN chmod 555 asciidocserver.sh

FROM base
VOLUME /var/asciidocserver
EXPOSE 80 443
CMD /opt/asciidocserver/asciidocserver.sh
