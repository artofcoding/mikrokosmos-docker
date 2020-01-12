ARG VERSION
FROM mikrokosmos/trac:${VERSION} AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos PM"

ARG PROJECT
ARG PROJECT_DIR=/var/trac/${PROJECT}
ARG DBLINK=postgres://trac:trac@trac-db:5432/dbname?schema=trac

FROM base
COPY trac*.sh /
RUN chmod 555 trac*.sh
CMD ["/trac.sh"]
