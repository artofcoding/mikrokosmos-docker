#!/bin/sh
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

PROJECT=MyProject

TRAC_DATA="/var/trac"
PROJECT_DIR="${TRAC_DATA}/${PROJECT}"
export PROJECT_DIR
#DBLINK="sqlite:${TRAC_DATA}/${PROJECT}.db"
DBLINK="postgres://trac:trac@trac-db:5432/trac?schema=trac"
export DBLINK

if [ ! -d "${PROJECT_DIR}" ]
then
    trac-admin "${PROJECT_DIR}" initenv "${PROJECT}" "${DBLINK}"
fi

# AgiloForTrac
# http://www.agilofortrac.com/documentation/installation-guide/
python ${TRAC_DATA}/trac-digest.py \
    -u username \
    -p password \
    >>${PROJECT_DIR}/users.digest
trac-admin "${PROJECT_DIR}" permission add username TRAC_ADMIN
#--auth=my_project,${PROJECT_DIR}/users.digest,trac
trac-admin "${PROJECT_DIR}" upgrade

# TODO http://trac.local/MyProject/wiki/TracStandalone#UsingAuthentication
#--auth="base_project_dir,password_file_path,realm"
tracd \
    --port 8000 \
    "${PROJECT_DIR}"

exit 0
