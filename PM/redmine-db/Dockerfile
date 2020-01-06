FROM postgres:12.1-alpine AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos PM"

FROM base
ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8
ENV POSTGRES_USER=redmine
ENV POSTGRES_PASSWORD=redmine
ENV POSTGRES_DB=redmine
