#!/usr/bin/env bash
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

CONTAINER_PREFIX=endpoint

set -o nounset
set -o errexit

function show_usage() {
    echo "usage: $0 init"
    echo "usage: $0 { up | start | stop | restart | down | ps }"
    echo "  start [<service>]"
    echo "  stop [<service>]"
    echo "  restart <service>"
    echo "usage: $0 { logs | exec | console | console-broken }"
    echo "  logs [-f] <service>"
    echo "  volumes <service>"
    echo "  exec <service> <command>"
    echo "  console <service>"
    echo "  console-broken <service>"
    exit 1
}
[[ $# -lt 1 ]] && show_usage

execdir=$(pushd "$(dirname $0)" >/dev/null ; pwd ; popd >/dev/null)
endpointdir=$(pushd "${execdir}/endpoint" >/dev/null ; pwd ; popd >/dev/null)
certdir=$(pushd "${endpointdir}/certs" >/dev/null ; pwd ; popd >/dev/null)

ENV_NAME="endpoint"
export ENV_NAME

CURRENT_BRANCH="$(git branch --show-current)"
HEAD_COMMIT_HASH="$(git rev-parse --short HEAD)"
CURRENT_TAG="$(git --no-pager tag -l --points-at HEAD)"
if [ -n "${CURRENT_TAG}" ]
then
    VERSION="${CURRENT_TAG:1}"
else
    VERSION="${CURRENT_BRANCH}-${HEAD_COMMIT_HASH}"
fi
export VERSION

function endpoint_docker() {
    docker-compose \
        -p "${CONTAINER_PREFIX}" \
        -f "${endpointdir}"/docker-compose.yml \
        "$@"
}

mode=${1:-} ; shift
case "${mode}" in
    build)
        endpoint_docker build \
            --build-arg "ENV_NAME=${ENV_NAME}" \
            --build-arg "VERSION=${VERSION}" \
            --compress
    ;;
    init)
        [[ $# == 1 ]] && CUSTOM_DOMAIN=$1
        endpoint_docker up -d
        endpoint_docker start port80
        endpoint_docker start rproxy-certbot
        endpoint_docker exec rproxy-certbot /nginx-tls.sh development self-signed
        endpoint_docker exec rproxy-certbot /nginx-tls.sh test self-signed
        endpoint_docker exec rproxy-certbot /nginx-tls.sh qa self-signed
        endpoint_docker exec rproxy-certbot /nginx-tls.sh production self-signed
        if [[ -n "${CUSTOM_DOMAIN:-}" ]]
        then
            if [[ -f "${certdir}/${CUSTOM_DOMAIN}"/privkey.pem \
               && -f "${certdir}/${CUSTOM_DOMAIN}"/intermediate.pem \
               && -f "${certdir}/${CUSTOM_DOMAIN}"/server.pem ]]
            then
                domain_cert_path="/etc/letsencrypt/custom/${CUSTOM_DOMAIN}"
                endpoint_docker exec rproxy-certbot mkdir -p "${domain_cert_path}"
                rproxycertbot="${ENV_NAME}_rproxy-certbot_1"
                docker cp "${certdir}/${CUSTOM_DOMAIN}"/privkey.pem "${rproxycertbot}:${domain_cert_path}"
                docker cp "${certdir}/${CUSTOM_DOMAIN}"/intermediate.pem "${rproxycertbot}:${domain_cert_path}"
                docker cp "${certdir}/${CUSTOM_DOMAIN}"/server.pem "${rproxycertbot}:${domain_cert_path}"
                endpoint_docker exec rproxy-certbot /nginx-tls.sh production custom
            fi
        fi
    ;;
    up)
        endpoint_docker up "$@"
    ;;
    start)
        endpoint_docker start "$@"
    ;;
    stop)
        endpoint_docker stop "$@"
    ;;
    restart)
        if [[ $# -lt 1 ]]
        then
            echo "usage: $0 restart <service ...>"
            exit 1
        fi
        endpoint_docker restart "$@"
    ;;
    ps)
        endpoint_docker ps
    ;;
    logs)
        endpoint_docker logs "$@"
    ;;
    exec)
        if [[ $# -lt 1 ]]
        then
            echo "usage: $0 exec <docker exec args>"
            exit 1
        fi
        endpoint_docker exec "$@"
    ;;
    console)
        if [[ $# -lt 1 ]]
        then
            echo "usage: $0 console <container>"
            exit 1
        fi
        endpoint_docker exec "$1" sh
    ;;
    console-broken)
        if [[ $# -lt 1 ]]
        then
            echo "usage: $0 console-broken <container>"
            exit 1
        fi
        # TODO container_status=$(docker ps -a --filter name=$1 --format '{{.Status}}')
        docker commit "$1" "$1_broken" && docker run -it "$1_broken" sh
    ;;
    *)
        show_usage
    ;;
esac

exit 0
