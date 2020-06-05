#!/usr/bin/env ash
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

sed -i'' -E \
        -e 's/^[#](HostKey)/\1/' \
        -e 's/^[#](ListenAddress 0|ListenAddress ::|Port)/\1/' \
        -e 's/^[#](Port ).*/\1 22/' \
        -e 's/^[#](PermitRootLogin).*/\1 no/' \
        -e 's/^[#](HostbasedAuthentication).*/\1 no/' \
        -e 's/^[#](ChallengeResponseAuthentication).*/\1 no/' \
        -e 's/^[#](PasswordAuthentication).*/\1 no/' \
        -e 's/^[#](PermitEmptyPasswords).*/\1 no/' \
        -e 's/^[#](IgnoreRhosts).*/\1 yes/' \
        -e 's/^[#](ClientAliveInterval).*/\1 300/' \
        -e 's/^[#](ClientAliveCountMax).*/\1 0/' \
        -e 's/^[#](Subsystem)\s+(sftp)\s+(.*)/#\1 \2 \3 -f AUTHPRIV -l INFO/' \
        /etc/ssh/sshd_config

exit 0
