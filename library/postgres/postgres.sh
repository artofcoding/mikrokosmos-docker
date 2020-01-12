#!/bin/sh
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

crond -f -L /dev/stdout &

PGDATA=/var/lib/postgresql/data
export PGDATA
/usr/local/bin/docker-entrypoint.sh postgres

exit 0
