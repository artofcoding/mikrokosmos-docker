#!/usr/bin/env bash
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

PREFIX=mikrokosmos

TRAC_PROJECT=MyProject
TRAC_VERSION=1.2.5

#
# DO NOT MODIFY LINES BELOW
#

set -o nounset
set -o errexit

export PREFIX

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

execdir="$(pushd "$(dirname $0)" >/dev/null ; pwd ; popd >/dev/null)"

function build_library() {
    local lib=$1
    echo ""
    echo "*"
    echo "* Building ${lib}:${VERSION}"
    echo "*"
    echo ""
    docker build \
        --build-arg "VERSION=${VERSION}" \
        -t "${PREFIX}/${lib}:${VERSION}" \
        "library/${lib}"
    echo "* done"
}

function build_needed() {
    for cnt in alpine-latest-stable maven nginx postgres
    do
        if [[ $(docker image ls | grep -c "mikrokosmos/${cnt}:${VERSION}") = 0 ]]
        then
            build_library "${cnt}"
        fi
    done
}

function docker_compose_build() {
    local prj=$1
    docker-compose \
        -p "${PREFIX}" \
        -f "docker-compose.${prj}.yml" \
        build \
        --build-arg "TRAC_PROJECT=${TRAC_PROJECT}" \
        --build-arg "VERSION=${VERSION}"
}

function docker_container_running() {
    local cnt=$1
    [[ "$(docker inspect \
              -f '{{.State.Running}}' \
              "${cnt}" 2>/dev/null)" == "true" ]] && return 0 || return 1
}

#echo "Mikrokosmos Version ${VERSION}"

cmd=${1:-usage}
case "${cmd}" in
    build-library)
        CONTAINERS=(alpine-latest-stable openssh-base maven nginx postgres redis redis-backup asciidocserver)
        for cnt in "${CONTAINERS[@]}"
        do
            echo -n "* Checking container ${cnt}"
            if [[ $(docker image ls | grep "${cnt}" | grep -c "${VERSION}") = 0 ]]
            then
                echo "... building"
                build_library "${cnt}"
            else
                echo "... image already built"
            fi
        done
    ;;
    build-cicd)
        echo ""
        echo "*"
        echo "* Building CICD"
        echo "*"
        echo ""
        docker_compose_build cicd
        echo "* done"
        echo "*"
        echo "* Building endpoint"
        echo "*"
        "${execdir}"/endpoint.sh build
        echo "* done"
    ;;
    build-pm)
        echo ""
        echo "*"
        echo "* Building PM -- trac"
        echo "*"
        echo ""
        docker build \
            --build-arg "VERSION=${VERSION}" \
            --build-arg "TRAC_PROJECT=${TRAC_PROJECT}" \
            --build-arg "TRAC_VERSION=${TRAC_VERSION}" \
            -t "${PREFIX}/trac:${VERSION}" \
            PM/trac
        echo "* done"
        echo ""
        echo "*"
        echo "* Building PM"
        echo "*"
        echo ""
        docker_compose_build pm
        echo "* done"
    ;;
    build-all)

    ;;
    local)
        echo ""
        echo "*"
        echo "* Building Reverse Proxy"
        echo "*"
        echo ""
        docker build \
            --build-arg "VERSION=${VERSION}" \
            -t "${PREFIX}/rproxy:${VERSION}" \
            rproxy
        echo "* done"
    ;;
    init)
        $0 stop
        $0 start
        echo "* done"
        echo ""
        echo "* Waiting 30 seconds to give systems a chance to initialize"
        echo ""
        sleep 30
        echo ""
        echo "* Initializing and running endpoint"
        echo ""
        "${execdir}"/endpoint.sh init
        echo ""
        echo "**************************************************"
        echo "*"
        echo "* Please adjust your host resolution (/etc/hosts)."
        echo "* See README.adoc."
        echo "*"
        echo "* Point your browser to"
        echo "*"
        #if docker_container_running mikrokosmos_youtrack_1
        #then
        #    YOUTRACK_PWD=$(docker exec \
        #        mikrokosmos_youtrack_1 \
        #        cat /opt/youtrack/conf/internal/services/configurationWizard/wizard_token.txt)
        #    echo "*     http://youtrack.local (${YOUTRACK_PWD:-})"
        #fi
        if docker_container_running mikrokosmos_trac-myproject_1
        then
            TRAC_PWD=$(docker logs mikrokosmos_trac-myproject_1 2>&1 \
                | grep "Password is" \
                | awk -F':' '{print $2}' \
                | tr -d ' ')
            echo "*     http://trac.local (${TRAC_PWD:-})"
        fi
        echo "*     http://redmine.local"
        if docker_container_running mikrokosmos_repo_1
        then
            NEXUS_PWD=$(docker exec mikrokosmos_nexus_1 \
                cat /nexus-data/admin.password)
            echo "*     http://repo.local (${NEXUS_PWD:-})"
        fi
        echo "*     http://quality.local"
        echo "*"
        echo "**************************************************"
        echo ""
    ;;
    letsencrypt)
        if docker_container_running mikrokosmos_trac-myproject_1
        then
            certbot run \
                -n \
                --nginx \
                --agree-tos --no-eff-email \
                --redirect \
                -m "support@${domain}" -d "trac.${domain}"
        fi
        if docker_container_running mikrokosmos_redmine_1
        then
            certbot run \
                -n \
                --nginx \
                --agree-tos --no-eff-email \
                --redirect \
                -m "support@${domain}" -d "redmine.${domain}"
        fi
        if docker_container_running mikrokosmos_sonarqube_1
        then
            certbot run \
                -n \
                --nginx \
                --agree-tos --no-eff-email \
                --redirect \
                -m "support@${domain}" -d "sonarqube.${domain}"
        fi
        if docker_container_running mikrokosmos_repo_1
        then
            certbot run \
                -n \
                --nginx \
                --agree-tos --no-eff-email \
                --redirect \
                -m "support@${domain}" -d "repo.${domain}"
        fi
    ;;
    ps)
        #-f docker-compose.yml \
        docker-compose \
            -p ${PREFIX} \
            -f docker-compose.pm.yml \
            -f docker-compose.cicd.yml \
            ps
    ;;
    start)
        echo ""
        echo "*"
        echo "* Running Project Management, CI/CD environment"
        echo "*"
        echo ""
        #-f docker-compose.yml \
        docker-compose \
            -p ${PREFIX} \
            -f docker-compose.pm.yml \
            -f docker-compose.cicd.yml \
            up -d
    ;;
    stop)
        #-f docker-compose.yml \
        docker-compose \
            -p ${PREFIX} \
            -f docker-compose.pm.yml \
            -f docker-compose.cicd.yml \
            stop
    ;;
    *)
        echo "usage: $0 <build-library | build-template | build | init | start | stop>"
        exit 1
    ;;
esac

exit 0
