ARG VERSION
FROM mikrokosmos/trac:${VERSION}

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos PM"

ARG PROJECT
ARG PROJECT_DIR=/var/trac/${PROJECT}
#ARG DBLINK=sqlite:db/${PROJECT}.db
ARG DBLINK=postgres://trac:trac@trac-db:5432/dbname?schema=trac

COPY trac.sh /
RUN chmod 555 trac.sh
CMD ["/trac.sh"]
