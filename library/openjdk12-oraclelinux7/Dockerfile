FROM openjdk:12.0.2-jdk-oraclelinux7 AS base
#FROM adoptopenjdk/openjdk12:jdk-12.0.1_12

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

ARG ENV_NAME
ARG ENV_TYPE
ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8

RUN yum -y install \
        tzdata \
        openssl \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && groupadd app \
    && useradd -g app app

RUN mkdir /opt/app \
    && mkdir /opt/app/bin \
    && mkdir /opt/app/conf
WORKDIR /opt/app
COPY create-truststore.sh bin/
COPY run-${ENV_TYPE}.sh bin/run.sh
RUN chmod 555 bin \
    && chmod 555 bin/* \
    && chmod 555 conf \
    && chmod 444 conf/*
RUN sed -i'' -E -e "s/(spring.profiles.active)=.*/\1=${ENV_TYPE}/" application.properties

USER app:app
VOLUME ["/opt/app"]
CMD ["/opt/app/bin/run.sh"]
