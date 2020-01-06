#!/bin/sh
#
# Copyright (C) 2018-2019 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

PROD_DOMAIN="www.example.org"
QA_DOMAIN="qa.example.org"
TEST_DOMAIN="test.example.org"
DEVELOPMENT_DOMAIN="localhost"

#
# DO NOT MODIFY LINES BELOW
#

set -o nounset
set -o errexit

if [ $# -ne 2 ]
then
    echo "usage: $0 <environment> <mode>"
    exit 1
fi

SELFSIGNED_PATH="/etc/letsencrypt/selfsigned"
LETSENCRYPT_LIVE_PATH="/etc/letsencrypt/live"
CUSTOM_PATH="/etc/letsencrypt/custom"

# TODO openssl rand 80 >/etc/nginx/ssl_session_ticket.key

env=${1:-} ; shift
mode=${1:-} ; shift

case "${env}" in
    development)
        DOMAIN="${DEVELOPMENT_DOMAIN}"
    ;;
    test)
        DOMAIN="${TEST_DOMAIN}"
    ;;
    qa)
        DOMAIN="${QA_DOMAIN}"
    ;;
    production)
        DOMAIN="${PROD_DOMAIN}"
    ;;
    *)
        echo "Unknwon environment ${env}"
        exit 1
    ;;
esac
NGINX_APP_CFG="/etc/nginx/conf.d/rproxy-${env}.nginx"

case "${mode}" in
    self-signed)
        domain_cert_path="${SELFSIGNED_PATH}/${DOMAIN}"
        mkdir -p ${domain_cert_path}
        if [ -f ${domain_cert_path}/privkey.pem ] || [ -f ${domain_cert_path}/fullchain.pem ]
        then
            echo "$0: ${domain_cert_path}/privkey.pem or fullchain.pem exists"
            exit 0
        fi
        openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
            -keyout ${domain_cert_path}/privkey.pem \
            -out ${domain_cert_path}/fullchain.pem \
            -subj "/CN=${DOMAIN}"
    ;;
    letsencrypt)
        domain_cert_path="${LETSENCRYPT_LIVE_PATH}/${DOMAIN}"
        mkdir -p ${domain_cert_path}
        if [ -f ${domain_cert_path}/privkey.pem ] || [ -f ${domain_cert_path}/fullchain.pem ]
        then
            echo "$0: ${domain_cert_path}/privkey.pem or fullchain.pem exists"
            exit 0
        fi
        certbot certonly \
            --register-unsafely-without-email --agree-tos \
            --webroot \
            --webroot-path=/usr/share/nginx/certbot \
            -n \
            -d ${DOMAIN}
        sed -i'' \
            -e "s/#ssl_stapling .*/ssl_stapling on;/" \
            -e "s/#ssl_stapling_verify .*/ssl_stapling_verify on;/" \
            ${NGINX_APP_CFG}
    ;;
    renew)
        certbot renew \
            -n \
            --nginx
    ;;
    custom)
        domain_cert_path=${CUSTOM_PATH}/${DOMAIN}
        mkdir -p ${domain_cert_path}
        if [ -f ${domain_cert_path}/server.pem ] && [ -f ${domain_cert_path}/intermediate.pem ]
        then
            cat ${domain_cert_path}/server.pem \
                ${domain_cert_path}/intermediate.pem \
                >>${domain_cert_path}/fullchain.pem
            sed -i'' \
                -e "s#ssl_certificate .*#ssl_certificate ${domain_cert_path}/fullchain.pem;#" \
                -e "s#ssl_certificate_key .*#ssl_certificate_key ${domain_cert_path}/privkey.pem;#" \
                -e "s#\#ssl_stapling .*#ssl_stapling on;#" \
                -e "s#\#ssl_stapling_verify .*#ssl_stapling_verify on;#" \
                ${NGINX_APP_CFG}
        fi
        if [ ! -f ${domain_cert_path}/ssl-dhparams.pem ]
        then
            #openssl dhparam -out ${domain_cert_path}/ssl-dhparams.pem 4096
            curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem \
                >${domain_cert_path}/ssl-dhparams.pem
        fi
        if [ -f ${domain_cert_path}/ssl-dhparams.pem ]
        then
            sed -i'' -E \
                -e "s#[\#]ssl_dhparam .*;#ssl_dhparam ${domain_cert_path}/ssl-dhparams.pem;#" \
                ${NGINX_APP_CFG}
        fi
    ;;
    *)
        echo "unknown command: $*"
        echo "usage: $0 <environment> { self-signed | letsencrypt | custom }"
        exit 1
    ;;
esac

exit 0
