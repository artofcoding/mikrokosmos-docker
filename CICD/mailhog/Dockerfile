FROM mikrokosmos/alpine-latest-stable:latest AS base

# Install ca-certificates, required for the "release message" feature:
RUN apk --no-cache add \
        ca-certificates \
    && apk --no-cache add --virtual build-dependencies \
        go \
        git \
    && mkdir -p /root/gocode \
    && export GOPATH=/root/gocode \
    && go get github.com/mailhog/MailHog \
    && mv /root/gocode/bin/MailHog /usr/local/bin \
    && rm -rf /root/gocode \
    && apk del --purge build-dependencies

RUN adduser -D -u 1000 mailhog

FROM base
USER mailhog
WORKDIR /home/mailhog
EXPOSE 1025 8025
ENTRYPOINT ["MailHog"]
