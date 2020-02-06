#!/usr/bin/env bash
#
# Copyright (C) 2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

TODAY=$(date +%Y%m%d_%H%M%S)
ARTEFACT="sac.lizenzportal.assembly.jar"
TARGET="lipproduction_app_1:/opt/lizenzportal/app/sac.lizenzportal.assembly.jar"

# Container solution
container=""
if [[ -x "$(command -v podman)" ]]
then
    container="podman"
elif [[ -x "$(command -v docker)" ]]
then
    container="docker"
fi
if [[ -z "${container}" ]]
then
    echo "No container management (podman or docker) found"
    exit 1
fi

function done_or_failed() {
    local ret=$1
    if [[ ${ret} -eq 0 ]]
    then
        echo " done"
    else
        echo " failed"
        exit 1
    fi
}

if [[ -f ${ARTEFACT} ]]
then
    [[ ! -d backup ]] && mkdir backup >/dev/null
    BACKUP="backup/${ARTEFACT}-${TODAY}"
    echo -n "Backing up ${TARGET} to ${BACKUP}..."
    ${container} cp "${TARGET}" "${BACKUP}"
    done_or_failed $?
    echo -n "Updating ${ARTEFACT} at ${TARGET}..."
    ${container} cp "${ARTEFACT}" "${TARGET}"
    done_or_failed $?
    echo "Restarting application..."
    lipproduction.sh restart app
    done_or_failed $?
    lipproduction.sh logs -f app
else
    echo "Artfact ${ARTEFACT} not found"
    exit 1
fi

exit 0
