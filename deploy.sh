#!/usr/bin/env bash
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

PREFIX=mikrokosmos

#
# DO NOT MODIFY LINES BELOW
#

set -o nounset
set -o errexit

CURRENT_BRANCH="$(git branch --show-current)"
HEAD_COMMIT_HASH="$(git rev-parse --short HEAD)"
VERSION="${CURRENT_BRANCH}-${HEAD_COMMIT_HASH}"
export VERSION

echo "*"
echo "* Version ${VERSION}"
echo "*"

echo "*"
echo "* Building alpine-latest-stable"
echo "*"
docker build -t ${PREFIX}/alpine-latest-stable:${VERSION} alpine-latest-stable

echo "*"
echo "* Building sshd-base"
echo "*"
docker build -t ${PREFIX}/sshd-base:${VERSION} sshd-base

echo "*"
echo "* Building asciidocserver"
echo "*"
docker build -t ${PREFIX}/asciidocserver:${VERSION} asciidocserver

echo "*"
echo "* Building CICD"
echo "*"
docker-compose -p ${PREFIX} -f CICD/docker-compose.yml build

echo "*"
echo "* Building PM"
echo "*"
docker-compose -p ${PREFIX} -f PM/docker-compose.yml build

echo "*"
echo "* Building Reverse Proxy"
echo "*"
docker build -t ${PREFIX}/rproxy:${VERSION} rproxy

echo "*"
echo "* Building Template/Endpoint"
echo "*"
docker-compose -p ${PREFIX} -f template/endpoint/docker-compose.yml build

exit 0
