ARG VERSION
FROM mikrokosmos/alpine-latest-stable:${VERSION} AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8

COPY sshdconfig.sh /

RUN apk update \
    && apk --no-cache add \
        tzdata \
        coreutils \
        openssh \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" >/etc/timezone \
    && chmod 555 /sshdconfig.sh \
    && /sshdconfig.sh \
    && rm /sshdconfig.sh \
    && ssh-keygen -A \
    && ssh-keygen -t rsa -b 4096 -q -N "" -f /etc/ssh/ssh_host_key \
    && mkdir /etc/ssh/keys

VOLUME ["/etc/ssh", "/etc/ssh/keys"]

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
