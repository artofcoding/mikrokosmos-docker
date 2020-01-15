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

USER root
RUN mkdir ${NEXUS_BACKUP} \
    && chown nexus:nexus ${NEXUS_BACKUP} \
    && chmod 700 ${NEXUS_BACKUP}

VOLUME ["/nexus-data", "/nexus-backup"]

USER nexus
CMD ["sh", "-c", "${SONATYPE_DIR}/start-nexus-repository-manager.sh"]

FROM base
COPY --chown=nexus:nexus nexus.properties ${NEXUS}/etc
RUN mkdir ${NEXUS_DATA}/restore-from-backup/ \
    && chmod -R 660 ${NEXUS_DATA}/restore-from-backup/
COPY --chown=nexus:nexus restore-from-backup/* ${NEXUS_DATA}/restore-from-backup/
EXPOSE 8081
