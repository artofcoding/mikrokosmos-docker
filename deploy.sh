#!/usr/bin/env bash
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

CONTAINER_SOLUTION="docker"
MIKROKOSMOS_DOMAIN=${MIKROKOSMOS_DOMAIN:-local}

#
# DO NOT MODIFY LINES BELOW
#

set -o nounset
set -o errexit

if [[ -z "${MIKROKOSMOS_DOMAIN}" ]]
then
    echo "MIKROKOSMOS_DOMAIN is not set"
    exit 1
fi

CONTAINER_PREFIX=mikrokosmos
TRAC_PROJECT=MyProject
TRAC_VERSION=1.2.5

execdir="$(pushd "$(dirname "$0")" >/dev/null ; pwd ; popd >/dev/null)"

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
export CONTAINER_PREFIX

# Container solution
container="${CONTAINER_SOLUTION:-}"
if [[ -z "${container}" ]]
then
    if [[ -x "$(command -v podman)" ]]
    then
        container="podman"
    elif [[ -x "$(command -v docker)" ]]
    then
        container="docker"
    fi
fi
if [[ -z "${container}" ]]
then
    echo "No container management (podman or docker) found"
    exit 1
fi

if [[ ${MIKROKOSMOS_DOMAIN} == "local" ]]
then
    COMPOSE_FILES="-f docker-compose.pm.yml -f docker-compose.cicd.yml -f docker-compose.local-rproxy.yml"
else
    COMPOSE_FILES="-f docker-compose.pm.yml -f docker-compose.cicd.yml"
fi

function build_library() {
    local lib=$1
    echo ""
    echo "*"
    echo "* Building ${lib}:${VERSION}"
    echo "*"
    echo ""
    ${container} build \
        --build-arg "VERSION=${VERSION}" \
        -t "${CONTAINER_PREFIX}/${lib}:${VERSION}" \
        "library/${lib}"
    echo "* done"
}

function build_needed() {
    for cnt in alpine-latest-stable maven nginx postgres
    do
        if [[ $(${container} image ls | grep -c "mikrokosmos/${cnt}:${VERSION}") == 0 ]]
        then
            build_library "${cnt}"
        fi
    done
}

function container_compose_build() {
    local prj=$1
    ${container}-compose \
        -p "${CONTAINER_PREFIX}" \
        -f "docker-compose.${prj}.yml" \
        build \
        --build-arg "VERSION=${VERSION}" \
        --build-arg "TRAC_PROJECT=${TRAC_PROJECT}"
}

function container_running() {
    local cnt=$1
    [[ "$(${container} inspect \
              -f '{{.State.Running}}' \
              "${cnt}" 2>/dev/null)" == "true" ]] && return 0 || return 1
}

cmd=${1:-usage} ; shift
case "${cmd}" in
    build-library)
        CONTAINERS=(alpine-latest-stable openssh-base maven nginx postgres redis redis-backup asciidocserver)
        for cnt in "${CONTAINERS[@]}"
        do
            echo ""
            echo -n "* Checking image ${cnt}"
            if [[ $(${container} image ls | grep "${cnt}" | grep -c "${VERSION}") = 0 ]]
            then
                echo "... building"
                build_library "${cnt}"
            else
                echo "... already built"
            fi
        done
    ;;
    build-cicd)
        echo ""
        echo "*"
        echo "* Building CICD"
        echo "*"
        echo ""
        # TODO Build needed container library
        container_compose_build cicd
        echo "* done"
    ;;
    build-pm)
        echo ""
        echo "*"
        echo "* Building PM -- trac"
        echo "*"
        echo ""
        # TODO Build needed container library
        ${container} build \
            --build-arg "VERSION=${VERSION}" \
            --build-arg "TRAC_PROJECT=${TRAC_PROJECT}" \
            --build-arg "TRAC_VERSION=${TRAC_VERSION}" \
            -t "${CONTAINER_PREFIX}/trac:${VERSION}" \
            PM/trac
        echo "* done"
        echo ""
        echo "*"
        echo "* Building PM"
        echo "*"
        echo ""
        container_compose_build pm
        echo "* done"
    ;;
    build-all)
        $0 build-library
        $0 build-pm
        $0 build-cicd
    ;;
    init)
        $0 down
        $0 build-all
        echo ""
        echo "*"
        echo "* Running Project Management and CI/CD environment"
        echo "*"
        echo ""
        $0 up
        if [[ "${MIKROKOSMOS_DOMAIN}" == "local" ]]
        then
            echo ""
            echo "*"
            echo "* Building local reverse proxy"
            echo "*"
            echo ""
            ${container} build \
                --build-arg "VERSION=${VERSION}" \
                -t "${CONTAINER_PREFIX}/local-rproxy:${VERSION}" \
                local-rproxy
            echo "* done"
            ${container}-compose \
                -p "${CONTAINER_PREFIX}" \
                ${COMPOSE_FILES} \
                build \
                --build-arg "VERSION=${VERSION}" \
                --build-arg "TRAC_PROJECT=${TRAC_PROJECT}"
            echo "* done"
        else
            echo ""
            echo "*"
            echo "* Initializing endpoint"
            echo "*"
            echo ""
            "${execdir}"/endpoint.sh build
            "${execdir}"/endpoint.sh init "${MIKROKOSMOS_DOMAIN}"
            echo ""
            echo "***************************************************"
            echo "*"
            echo "* You may run $0 letsencrypt to issue Let's Encrypt"
            echo "* TLS certificates."
            echo "*"
            echo "***************************************************"
            echo ""
        fi
        echo ""
        secs=60
        echo "* Waiting ${secs} seconds to give systems a chance to initialize"
        echo ""
        sleep ${secs}
        echo ""
        echo "**************************************************"
        echo "*"
        echo "* Please adjust your host resolution (/etc/hosts)."
        echo "* See README.adoc."
        echo "*"
        echo "* Point your browser to"
        echo "*"
        #if container_running mikrokosmos_youtrack_1
        #then
        #    YOUTRACK_PWD=$(docker exec \
        #        mikrokosmos_youtrack_1 \
        #        cat /opt/youtrack/conf/internal/services/configurationWizard/wizard_token.txt)
        #    echo "*     http://youtrack.local (${YOUTRACK_PWD:-})"
        #fi
        if container_running mikrokosmos_trac-myproject_1
        then
            TRAC_PWD=$(${container} logs mikrokosmos_trac-myproject_1 2>&1 \
                | grep "Password is" \
                | awk -F':' '{print $2}' \
                | tr -d ' ')
            echo "*     http://trac.local (${TRAC_PWD:-})"
        fi
        echo "*     http://redmine.local"
        if container_running mikrokosmos_repo_1
        then
            NEXUS_PWD=$(${container} exec mikrokosmos_nexus_1 \
                cat /nexus-data/admin.password)
            echo "*     http://nexus.local (${NEXUS_PWD:-})"
        fi
        echo "*     http://sonarqube.local"
        echo "*"
        echo "**************************************************"
        echo ""
    ;;
    letsencrypt)
        if [[ ${MIKROKOSMOS_DOMAIN} == "local" ]]
        then
            echo "Cannot generate TLS certificates for domain .local"
            exit 1
        fi
        if container_running mikrokosmos_trac-myproject_1
        then
            certbot run \
                -n \
                --nginx \
                --agree-tos --no-eff-email \
                --redirect \
                -m "support@${MIKROKOSMOS_DOMAIN}" -d "trac.${MIKROKOSMOS_DOMAIN}"
        fi
        if container_running mikrokosmos_redmine_1
        then
            certbot run \
                -n \
                --nginx \
                --agree-tos --no-eff-email \
                --redirect \
                -m "support@${MIKROKOSMOS_DOMAIN}" -d "redmine.${MIKROKOSMOS_DOMAIN}"
        fi
        if container_running mikrokosmos_sonarqube_1
        then
            certbot run \
                -n \
                --nginx \
                --agree-tos --no-eff-email \
                --redirect \
                -m "support@${MIKROKOSMOS_DOMAIN}" -d "sonarqube.${MIKROKOSMOS_DOMAIN}"
        fi
        if container_running mikrokosmos_nexus_1
        then
            certbot run \
                -n \
                --nginx \
                --agree-tos --no-eff-email \
                --redirect \
                -m "support@${MIKROKOSMOS_DOMAIN}" -d "nexus.${MIKROKOSMOS_DOMAIN}"
        fi
    ;;
    ps)
        ${container}-compose \
            -p ${CONTAINER_PREFIX} \
            ${COMPOSE_FILES} \
            ps
    ;;
    logs)
        docker logs "${CONTAINER_PREFIX}_$1_1"
    ;;
    up)
        ${container}-compose \
            -p ${CONTAINER_PREFIX} \
            ${COMPOSE_FILES} \
            up -d
    ;;
    down)
        ${container}-compose \
            -p ${CONTAINER_PREFIX} \
            ${COMPOSE_FILES} \
            down
    ;;
    start)
        ${container}-compose \
            -p ${CONTAINER_PREFIX} \
            ${COMPOSE_FILES} \
            start "$@"
    ;;
    stop)
        ${container}-compose \
            -p ${CONTAINER_PREFIX} \
            ${COMPOSE_FILES} \
            stop "$@"
    ;;
    *)
        echo "usage: $0 <build-library | build-template | build-all>"
        echo "usage: $0 <init>"
        echo "usage: $0 <letsencrypt>"
        echo "usage: $0 <up | down>"
        echo "usage: $0 <start | stop> <service1> [<serviceN> ...]"
        exit 1
    ;;
esac

exit 0
