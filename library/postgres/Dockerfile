FROM postgres:12.1-alpine AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

FROM base
ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8

COPY --from=postgres:12.1-alpine /usr/local/bin/docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

COPY --chown=postgres:postgres *.sh /
RUN chmod 555 /*.sh \
    && echo "0 0 * * * /backup.sh" | crontab -
CMD ["/postgres.sh"]
