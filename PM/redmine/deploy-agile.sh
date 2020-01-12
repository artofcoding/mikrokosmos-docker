#!/bin/sh
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

AGILE_DIST=redmine_agile-1_5_1-light.zip

if [ -f ${AGILE_DIST} ]
then
    docker cp ${AGILE_DIST} mikrokosmos_redmine_1:/tmp
    unzip -d /usr/src/redmine/plugins /tmp/${AGILE_DIST} \
        && bundle install \
        && bundle exec rake redmine:plugins NAME=redmine_agile RAILS_ENV=production
fi

exit 0
