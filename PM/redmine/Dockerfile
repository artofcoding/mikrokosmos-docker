FROM redmine:4.1 AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos PM"

FROM base
ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8
ENV REDMINE_DB_POSTGRES=redmine-db
ENV REDMINE_DB_USERNAME=redmine
ENV REDMINE_DB_PASSWORD=redmine
