ARG VERSION
FROM mikrokosmos/trac:${VERSION} AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos PM"

FROM base
COPY trac*.sh /
RUN chmod 555 trac*.sh
CMD ["/trac.sh"]
