#!/usr/bin/env bash
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

#
# DO NOT MODIFY LINES BELOW
#

set -o nounset
set -o errexit

if [[ $(basename $0) == dc.sh ]]
then
    echo "Please do not call this script directly."
    echo "Use a link:"
    echo "  ln -s dc.sh <envname>.sh and create etc/<envname>.env"
    exit 1
fi

if [[ $# -lt 1 ]]
then
    echo "usage: $0 { assembly | build-images | clean-images }"
    echo "usage: $0 { init }"
    echo "usage: $0 { up | start | stop | restart | down | ps }"
    echo "  start [<service>]"
    echo "  stop [<service>]"
    echo "  restart <service>"
    echo "usage: $0 { logs | volumes | exec | console | console-broken }"
    echo "  logs [-f] <service>"
    echo "  volumes <service>"
    echo "  exec <service> <command>"
    echo "  console <service>"
    echo "  console-broken <service>"
    exit 1
fi

execdir=$(pushd "$(dirname $0)" >/dev/null ; pwd ; popd >/dev/null)
basedir=$(pushd "${execdir}/../.." >/dev/null ; pwd ; popd >/dev/null)
dockerdir=$(pushd "${execdir}/.." >/dev/null ; pwd ; popd >/dev/null)
etcdir=$(pushd "${execdir}/../etc" >/dev/null ; pwd ; popd >/dev/null)
vardir=$(pushd "${execdir}/../var" >/dev/null ; pwd ; popd >/dev/null)

ENV_NAME=$(expr "$(basename $0)" : '\(.*\).sh')
echo "Environment: ${ENV_NAME}"
. "${etcdir}/${ENV_NAME}".env

export ENV_NAME
export ENV_TYPE
export USER_ID
export GROUP_ID

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

function dc() {
    docker-compose \
        -p "${ENV_NAME}" \
        -f "${dockerdir}"/docker-compose.yml \
        -f "${dockerdir}"/docker-compose."${ENV_TYPE}".yml \
        "$@"
}

mode=${1:-}
shift
case "${mode}" in
    assembly)
        prjdir=$(pushd "${execdir}"/../../ >/dev/null ; pwd ; popd >/dev/null)
        pushd "${prjdir}" >/dev/null || exit
        ./build.sh assembly
        popd >/dev/null || exit
    ;;
    build-images)
        dc build \
            --build-arg "ENV_NAME=${ENV_NAME}" \
            --build-arg "ENV_TYPE=${ENV_TYPE}" \
            --compress
    ;;
    init)
        $0 build-images
        dc up --no-start
        app="${ENV_NAME}_app_1"
        starter="${app}_starter"
        [[ $(docker ps -aq -f name=${starter} | wc -l | tr -d ' ') -gt 0 ]] && docker rm -f ${starter}
        docker run -itd --name ${starter} --volumes-from ${app} alpine:3.10 tail -f /dev/null
        # App
        if [[ -f ${etcdir}/secrets.json ]]
        then
            APP_HOME=/opt/app
            docker cp ${etcdir}/secrets-${ENV_TYPE}.json ${starter}:${APP_HOME}/conf/secrets.json
            docker exec -u root ${starter} chown ${USER_ID}:${GROUP_ID} ${APP_HOME}/conf/secrets.json
            docker exec -u root ${starter} chmod 400 ${APP_HOME}/conf/secrets.json
        fi
        docker rm -f ${starter}
    ;;
    up)
        dc up -d "$@"
    ;;
    start)
        if [[ $# -lt 1 ]]
        then
            echo "usage: $0 start <service ...>"
            exit 1
        fi
        dc start "$@"
    ;;
    stop)
        if [[ $# -lt 1 ]]
        then
            echo "usage: $0 stop <service ...>"
            exit 1
        fi
        dc stop "$@"
    ;;
    restart)
        if [[ $# -lt 1 ]]
        then
            echo "usage: $0 restart <service ...>"
            exit 1
        fi
        dc restart "$@"
    ;;
    down)
        dc down
    ;;
    ps)
        dc ps
    ;;
    logs)
        if [[ $# -lt 1 ]]
        then
            echo "usage: $0 logs [-f] <service>"
            exit 1
        fi
        dc logs "$@"
    ;;
    volumes)
        if [[ $# -lt 1 ]]
        then
            echo "usage: $0 volumes <container>"
            exit 1
        fi
        container=$1
        docker inspect "${container}" -f '{{json .Mounts}}' | jq
    ;;
    exec)
        if [[ $# -lt 1 ]]
        then
            echo "usage: $0 exec <docker exec args>"
            exit 1
        fi
        dc exec "$@"
    ;;
    console)
        if [[ $# -lt 1 ]]
        then
            echo "usage: $0 console <container>"
            exit 1
        fi
        container=$1
        dc exec "${container}" sh
    ;;
    console-broken)
        if [[ $# -lt 1 ]]
        then
            echo "usage: $0 console-broken <container>"
            exit 1
        fi
        container=$1
        # TODO container_status=$(docker ps -a --filter name=$1 --format '{{.Status}}')
        docker commit "${container}" "${container}_broken" \
            && docker run -it "${container}_broken" sh
    ;;
    backup)
        if [[ $# -lt 1 ]]
        then
            echo "usage: $0 backup <container>"
            exit 1
        fi
        container=$1
        backup_container="${container}_backup"
        docker commit --pause=false "${container}" "${backup_container}"
        docker save -o "${backup_container}".tar "${backup_container}"
        gzip -9 "${backup_container}".tar
        docker rm "${backup_container}"
        # TODO Backup its volumes
        #docker inspect ${container} --format '{{.Mounts}}'
    ;;
    backup-mysql)
        if [[ $# -lt 2 ]]
        then
            echo "usage: $0 backup-mysql <container> <database>"
            exit 1
        fi
        container=$1 ; shift
        database=$1
        # TODO https://hub.docker.com/r/deitch/mysql-backup/
        #docker run -d --restart=always \
        #    -e DB_DUMP_FREQ=60 \
        #    -e DB_DUMP_BEGIN=2330 \
        #    -e DB_DUMP_TARGET=/db \
        #    -e DB_SERVER=$1 \
        #    -v ${DOCKER_BACKUP_DIR}:/db \
        #    databack/mysql-backup
        # Setup /root/.my.cnf, section [client] in container before
        docker exec ${container} \
            /usr/bin/mysqldump ${container} \
            | gzip -9 >${DOCKER_BACKUP_DIR}/mysql-${database}-$(date +%Y%m%d_%H%M%S).sql.gz
    ;;
    health)
        docker inspect --format='{{json .State.Health}}'
    ;;
    compose)
        dc "$@"
    ;;
    *)
        echo "usage: $0 ..."
        exit 1
    ;;
esac

exit 0
