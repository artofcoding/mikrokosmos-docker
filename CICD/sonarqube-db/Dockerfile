FROM postgres:12.1-alpine AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos CICD"

FROM base

ENV POSTGRES_USER=sonar
ENV POSTGRES_PASSWORD=sonar
ENV POSTGRES_DB=sonarqube

EXPOSE 5432
