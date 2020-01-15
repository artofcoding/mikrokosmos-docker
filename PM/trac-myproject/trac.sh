#!/bin/sh
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

TRAC_PROJECT=MyProject

TRAC_DATA="/var/trac"
TRAC_PROJECT_DIR="${TRAC_DATA}/${TRAC_PROJECT}"
export TRAC_PROJECT_DIR

./trac-install.sh

echo ""
echo "* Starting Trac"
tracd \
    --http11 \
    --port 8000 \
    --auth="${TRAC_PROJECT},${TRAC_PROJECT_DIR}/users.digest,trac" \
    -s \
    "${TRAC_PROJECT_DIR}"

exit 0
