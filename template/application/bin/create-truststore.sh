#!/usr/bin/env bash
#
# Copyright (C) 2018-2019 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

set -o nounset
set -o errexit

TMP=${1:-tmp$$}
echo "Using temporary directory ${TMP}"
mkdir "${TMP}"

function insert_https_cert() {
    local host=$1
    echo "Download HTTPS certificate from ${host}"
    openssl s_client \
        -connect "${host}:443" \
        </dev/null 2>/dev/null \
        | openssl x509 -outform PEM >"${TMP}/${host}.cert.pem" \
        && keytool -noprompt -importcert \
            -storetype JKS -keystore "${TMP}/truststore.jks" \
            -storepass changeit \
            -trustcacerts \
            -alias "${host}" -file "${TMP}/${host}.cert.pem"
}

function insert_smtps_cert() {
    local host=$1
    echo "Download SMTPS certificate from ${host}"
    openssl s_client \
        -starttls smtp -connect "${host}:587" \
        </dev/null 2>/dev/null \
        | openssl x509 -outform PEM >"${TMP}/${host}.cert.pem" \
        && keytool -noprompt -importcert \
            -storetype JKS -keystore "${TMP}/truststore.jks" \
            -storepass changeit \
            -trustcacerts \
            -alias "${host}" -file "${TMP}/${host}.cert.pem"
}

function move_truststore_to() {
    mv "${TMP}/truststore.jks" .
    if [[ "${TMP}" == "tmp*" && -d "${TMP}" ]]
    then
        echo "Removing temporary directory ${TMP}"
        rm -rf "${TMP}"
    fi
}

#insert_https_cert softandcloud.softandcloud.net
#insert_smtps_cert smtp.1und1.de
#move_truststore_to

exit 0
