#!/usr/bin/env bash
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

DOCKER_IMAGE_PREFIX=mikrokosmos
CONTAINERS="port80 rproxy rproxy-certbot"

set -o nounset
set -o errexit

if [[ $# -lt 1 ]]
then
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
fi

execdir=$(pushd `dirname $0` >/dev/null ; pwd ; popd >/dev/null)
basedir=$(pushd "${execdir}/../.." >/dev/null ; pwd ; popd >/dev/null)
dockerdir=$(pushd "${execdir}/.." >/dev/null ; pwd ; popd >/dev/null)
etcdir=$(pushd "${execdir}/../etc" >/dev/null ; pwd ; popd >/dev/null)

ENV_NAME="endpoint"
export ENV_NAME
VERSION=$(cat ${basedir}/.version)
export VERSION

function endpoint_docker() {
    docker-compose \
        -p ${ENV_NAME} \
        -f ${dockerdir}/docker-compose.endpoint.yml \
        "$@"
}

mode=${1:-} ; shift
case "${mode}" in
    build-images)
        endpoint_docker build \
            --build-arg ENV_NAME=${ENV_NAME} \
            --compress
    ;;
    clean-images)
        if [[ $# != 1 ]]
        then
            echo "usage: $0 clean-images <tag>"
            exit 1
        fi
        tag=$1
        set +o errexit
        for container in ${CONTAINERS}
        do
            docker image rm ${DOCKER_IMAGE_PREFIX}/endpoint-${container}:${tag}
        done
        set -o errexit
    ;;
    remove)
        set +o errexit
        $0 down
        docker volume rm endpoint_port80_etc_nginx
        docker volume rm endpoint_rproxy_etc_nginx
        docker volume rm endpoint_rproxy_html
        set -o errexit
    ;;
    init)
        $0 build-images
        endpoint_docker up -d
        endpoint_docker start port80
        endpoint_docker start rproxy-certbot
        endpoint_docker exec rproxy-certbot /nginx-tls.sh development self-signed
        endpoint_docker exec rproxy-certbot /nginx-tls.sh test self-signed
        endpoint_docker exec rproxy-certbot /nginx-tls.sh qa self-signed
        endpoint_docker exec rproxy-certbot /nginx-tls.sh production self-signed
        # production
        ls ${HOME}/*.pem >/dev/null 2>&1
        [[ $? == 0 ]] && cp ${HOME}/*.pem ${etcdir}
        if [[ -f ${etcdir}/privkey.pem && -f ${etcdir}/intermediate.pem && -f ${etcdir}/server.pem  ]]
        then
            domain_cert_path="/etc/letsencrypt/custom/portal.softandcloud.net"
            endpoint_docker exec rproxy-certbot mkdir -p ${domain_cert_path}
            rproxycertbot="${ENV_NAME}_rproxy-certbot_1"
            docker cp ${etcdir}/privkey.pem ${rproxycertbot}:${domain_cert_path}
            docker cp ${etcdir}/intermediate.pem ${rproxycertbot}:${domain_cert_path}
            docker cp ${etcdir}/server.pem ${rproxycertbot}:${domain_cert_path}
            endpoint_docker exec rproxy-certbot /nginx-tls.sh production custom
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
    down)
        endpoint_docker down "$@"
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
        echo "usage: $0 ..."
        exit 1
    ;;
esac

exit 0
