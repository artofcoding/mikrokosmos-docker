FROM opensuse/leap:15.1 AS base

LABEL maintainer="Ralf Bensmann <ralf@art-of-coding.eu>"
LABEL vendor="Art of Coding UG"
LABEL project="Mikrokosmos CICD"

RUN zypper --non-interactive install -y \
        hostname which curl \

RUN curl -L \
        https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh \
        | bash

ARG EXTERNAL_URL=http://gitlab.local
RUN echo "${EXTERNAL_URL}" >/etc/hostname \
    && EXTERNAL_URL="${EXTERNAL_URL}" \
        zypper --non-interactive install -y gitlab-ce
