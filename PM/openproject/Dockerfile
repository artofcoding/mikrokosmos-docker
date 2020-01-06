FROM openproject/community:10.3 AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos PM"

FROM base
ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8
ENV SECRET_KEY_BASE=secret
ENV EMAIL_DELIVERY_METHOD=smtp
ENV SMTP_ADDRESS=smtp.sendgrid.net
ENV SMTP_PORT=587
ENV SMTP_DOMAIN=my.domain.com
ENV SMTP_AUTHENTICATION=login
ENV SMTP_ENABLE_STARTTLS_AUTO=true
ENV SMTP_USER_NAME=apikey
ENV SMTP_PASSWORD=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

VOLUME ["/var/openproject/pgdata", "/var/openproject/assets"]
