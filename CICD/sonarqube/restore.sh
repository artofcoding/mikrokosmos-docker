#!/usr/bin/env bash
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

# See http://quality.local/web_api/
# See https://github.com/AssafKatz3/SonarQube_Settings_Over_GIT

GATES="AoC%20way"

#
# DO NOT MODIFY LINES BELOW
#

set -o nounset
set -o errexit

REPOSITORY_URL="http://localhost:9000/api"

IMPORT_QUALITY_GATE="/qualitygates/"

curl \
    -X POST \
    --basic admin:admin
    --data @

exit 0
