#!/usr/bin/env bash
#
# Copyright (C) 2018-2019 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

set -o nounset
set -o errexit

umask 0007
TZ="Europe/Berlin"
export TZ

cd /opt/lizenzportal
ls -lR
SPRING_APPLICATION_JSON="$(cat conf/secrets.json)" \
    java \
        -Xms2g -Xmx4g \
        -Djavax.net.ssl.trustStore=/opt/lizenzportal/conf/truststore.jks \
        -jar app/sac.lizenzportal.assembly.jar \
            --spring.profiles.active=qa \
            --spring.config.additional-location=conf/ \

exit 0
