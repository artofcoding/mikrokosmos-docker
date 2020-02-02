#!/usr/bin/env bash
#
# Copyright (C) 2018-2019 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

PROJECT_NAME="my.project"
REPO_NAME="example/${PROJECT_NAME}.git"
ASSEMBLY_MAVEN_PROFILES=""

REPO_HOST=git@bitbucket.org
PROJECT_DIR="${HOME}/${PROJECT_NAME}"

#
# DO NOT MODIFY LINES BELOW
#

set -o nounset
set -o errexit

if [[ $# != 2 ]]
then
    echo "usage: $0 <environment> <init | update>"
    exit 1
fi

function guess_branch() {
    local tag=${1:-}
    if [[ -n "${tag}" ]]
    then
        BRANCH="${tag}"
    else
        case "${env}" in
            development)
                BRANCH="develop"
            ;;
            test)
                BRANCH="develop"
            ;;
            qa)
                BRANCH="develop"
            ;;
            production)
                BRANCH="master"
            ;;
            *)
                echo "$0: unknown environment ${env}"
                exit 1
            ;;
        esac
    fi
}

function resethard_update_repo() {
    if [[ ! -d "${PROJECT_DIR}" ]]
    then
        git clone -b "${BRANCH}" "${REPO_HOST}:${REPO_NAME}" "${PROJECT_DIR}"
    fi
    pushd "${PROJECT_DIR}" >/dev/null
    git reset --hard
    git fetch origin "${BRANCH}"
    git checkout "${BRANCH}"
    git pull
    VERSION="${BRANCH}-$(git rev-parse --short HEAD)"
    echo "${VERSION}" >.version
    popd >/dev/null
}

env="$1" ; shift
dcenv="lip${env}"
execdir=$(pushd "$(dirname "$0")" >/dev/null ; pwd ; popd >/dev/null)
etcdir=$(pushd "${execdir}/etc" >/dev/null ; pwd ; popd >/dev/null)
vardir=$(pushd "${execdir}/var" >/dev/null ; pwd ; popd >/dev/null)
pushd "${execdir}" >/dev/null
popd >/dev/null

PATH=${PROJECT_DIR}/docker/bin:$PATH
export PATH

mode=${1:-} ; shift
tag=${1:-}
guess_branch "${tag}"
echo "Environment: ${dcenv} - Branch ${BRANCH}"
case "${mode}" in
    build)
        resethard_update_repo
        if [[ -n "${ASSEMBLY_MAVEN_PROFILES}" ]]
        then
            mvnp="-P ${ASSEMBLY_MAVEN_PROFILES}"
        else
            mvnp=""
        fi
        ./mvnw ${mvnp} \
            org.codehaus.mojo:versions-maven-plugin:2.7:set \
            -DnewVersion="${VERSION}"
        ./mvnw ${mvnp} \
            clean install
    ;;
    init)
        $0 "${env}" build
        cp "${HOME}/secrets-${env}.json" docker/etc
        "${dcenv}.sh" init
        # TODO Verify if endpoint is set up
        echo "*"
        echo "* Starting endpoint"
        echo "*"
        endpoint.sh start
        echo "*"
        echo "* Starting ${PROJECT_NAME}"
        echo "*"
        "${dcenv}.sh" start
    ;;
    update)
        $0 "${env}" build
        docker cp \
            "${PROJECT_DIR}"/assembly/target/"${PROJECT_NAME}".assembly.jar \
            "${dcenv}"_app:/opt/app
        # TODO Verify if Docker container is running
        "${dcenv}.sh" restart app
    ;;
    *)
        echo "$0: unknown mode ${mode}"
        exit 1
    ;;
esac

exit 0
