ARG VERSION
FROM mikrokosmos/postgres:${VERSION} AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos CICD"

FROM base
ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8
ENV POSTGRES_USER=sonar
ENV POSTGRES_PASSWORD=sonar
ENV POSTGRES_DB=sonarqube

EXPOSE 5432
