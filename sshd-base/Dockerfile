FROM mikrokosmos/alpine-latest-stable:latest AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos"

ENV TZ Europe/Berlin
ENV LANG en_US.UTF-8

RUN apk update \
    && apk --no-cache add \
        tzdata \
        coreutils \
        openssh \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" >/etc/timezone \
    && sed -i'' -E \
        -e 's/^[#](HostKey)/\1/' \
        -e 's/^[#](ListenAddress 0|ListenAddress ::|Port)/\1/' \
        -e 's/^[#](Port ).*/\1 22/' \
        -e 's/^[#](PermitRootLogin).*/\1 no/' \
        -e 's/^[#](HostbasedAuthentication).*/\1 no/' \
        -e 's/^[#](ChallengeResponseAuthentication).*/\1 no/' \
        -e 's/^[#](PasswordAuthentication).*/\1 no/' \
        -e 's/^[#](PermitEmptyPasswords).*/\1 no/' \
        -e 's/^[#](IgnoreRhosts).*/\1 yes/' \
        -e 's/^[#](ClientAliveInterval).*/\1 300/' \
        -e 's/^[#](ClientAliveCountMax).*/\1 0/' \
        -e 's/^[#](Subsystem)\s+(sftp)\s+(.*)/#\1 \2 \3 -f AUTHPRIV -l INFO/' \
        /etc/ssh/sshd_config \
    && ssh-keygen -A \
    && ssh-keygen -t rsa -b 4096 -q -N "" -f /etc/ssh/ssh_host_key \
    && mkdir /etc/ssh/keys

VOLUME ["/etc/ssh", "/etc/ssh/keys"]

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
