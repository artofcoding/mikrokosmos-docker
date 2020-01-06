#!/bin/sh
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

npm install
npm start -- \
    --bookroot=/var/asciidocserver/book \
    --blogroot=/var/asciidocserver/blog

exit 0
