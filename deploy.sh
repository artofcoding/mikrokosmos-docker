#!/usr/bin/env bash
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

PREFIX=mikrokosmos
PROJECT=MyProject

#
# DO NOT MODIFY LINES BELOW
#

set -o nounset
set -o errexit

export PREFIX
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
docker build \
    -t ${PREFIX}/alpine-latest-stable:${VERSION} \
    alpine-latest-stable

echo "*"
echo "* Building openssh-base"
echo "*"
docker build \
    --build-arg VERSION=${VERSION} \
    -t ${PREFIX}/openssh-base:${VERSION} \
    openssh-base

echo "*"
echo "* Building asciidocserver"
echo "*"
docker build \
    --build-arg VERSION=${VERSION} \
    -t ${PREFIX}/asciidocserver:${VERSION} \
    asciidocserver

echo "*"
echo "* Building CICD"
echo "*"
docker-compose \
    -p ${PREFIX} \
    -f docker-compose.cicd.yml \
    build \
    --build-arg PROJECT=${PROJECT} \
    --build-arg VERSION=${VERSION}

echo "*"
echo "* Building PM -- trac"
echo "*"
docker build \
    --build-arg VERSION=${VERSION} \
    --build-arg PROJECT=${PROJECT} \
    -t ${PREFIX}/trac:${VERSION} \
    PM/trac
echo "*"
echo "* Building PM"
echo "*"
docker-compose \
    -p ${PREFIX} \
    -f docker-compose.pm.yml \
    build \
    --build-arg PROJECT=${PROJECT} \
    --build-arg VERSION=${VERSION}

echo "*"
echo "* Building Reverse Proxy"
echo "*"
docker build \
    --build-arg VERSION=${VERSION} \
    -t ${PREFIX}/rproxy:${VERSION} \
    rproxy

echo "*"
echo "* Building Endpoint"
echo "*"
endpoint/endpoint.sh build-images

echo "*"
echo "* Running CICD, PM w/ Reverse Proxy"
echo "*"
docker-compose \
    -p ${PREFIX} \
    -f docker-compose.yml \
    -f docker-compose.pm.yml \
    -f docker-compose.cicd.yml \
    up -d

#echo "*"
#echo "* Running Reverse Proxy as standalone container"
#echo "*"
#docker run \
#    --name mikrokosmos_rproxy \
#    --network mikrokosmos_cicd \
#    -d \
#    -p 80:80 \
#    mikrokosmos/rproxy:${VERSION}

echo "**************************************************"
echo "*"
echo "* Please adjust your host resolution (/etc/hosts)."
echo "* See README.adoc."
echo "*"
echo "* Point your browser to"
echo "*     http://trac.local"
echo "*     http://repo.local"
echo "*     http://quality.local"
echo "*"
echo "**************************************************"

exit 0
