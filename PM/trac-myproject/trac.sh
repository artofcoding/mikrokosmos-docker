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

./trac-install.sh

echo ""
echo "* Starting Trac"
tracd \
    --http11 \
    --port 8000 \
    --auth="${PROJECT},${PROJECT_DIR}/users.digest,trac" \
    -s \
    "${PROJECT_DIR}"

exit 0
