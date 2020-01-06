ARG VERSION
FROM sonatype/nexus3:3.20.0 AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos CICD"

ARG NEXUS=/opt/sonatype/nexus
ARG NEXUS_BACKUP=/nexus-backup

ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8
ENV SONATYPE_DIR=/opt/sonatype
ENV NEXUS_DATA=/nexus-data

RUN rm -rf ${NEXUS_DATA}/db/component \
    && rm -rf ${NEXUS_DATA}/db/config \
    && rm -rf ${NEXUS_DATA}/db/security \
    && mkdir -p ${NEXUS_DATA}/restore-from-backup/

COPY nexus.properties ${NEXUS}/etc

USER root
RUN mkdir ${NEXUS_DATA}/restore-from-backup/ \
    && chown -R nexus:nexus ${NEXUS_DATA}/restore-from-backup/ \
    && chmod -R 660 ${NEXUS_DATA}/restore-from-backup/ \
    && mkdir ${NEXUS_BACKUP} \
    && chown nexus:nexus ${NEXUS_BACKUP} \
    && chmod 700 ${NEXUS_BACKUP}

VOLUME ["/nexus-data", "/nexus-backup"]

USER nexus
CMD ["sh", "-c", "${SONATYPE_DIR}/start-nexus-repository-manager.sh"]

FROM base
ARG timestamp=2019-12-15-08
COPY *-${timestamp}*.bak ${NEXUS_DATA}/restore-from-backup/
EXPOSE 8081
