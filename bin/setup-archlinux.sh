#!/usr/bin/env bash
#
# Copyright (C) 2019 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

set -o nounset
set -o errexit

if [[ "$(id -un)" != "root" ]]
then
    echo "Please execute as root"
    exit 1
fi

#
# Time
#

[ ! -f /etc/localtime ] && cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime
echo "Europe/Berlin" >/etc/timezone
#echo "LANG=de_DE.UTF-8" >/etc/locale.conf
echo "LANG=en_US.UTF-8" >/etc/locale.conf

#
# Linux Packages
#

pacman --noconfirm -Syyu

pacman --noconfirm -S sudo
#archlinux_install linux-lts
#grub-mkconfig -o /boot/grub/grub.cfg
pacman --noconfirm -S git

#
# SSH
#

pkfile="${HOME}/.ssh/id_rsa"
if [[ ! -f "${pkfile}" ]]
then
    ssh-keygen -t rsa -b 4096 -N "" -f "${pkfile}"
fi
set +o errexit
ssh-keygen -R github.com
ssh-keygen -R bitbucket.org
set -o errexit
ssh-keyscan github.com >>${HOME}/.ssh/known_hosts
ssh-keyscan bitbucket.org >>${HOME}/.ssh/known_hosts

#
# Docker
#

# Install Docker
pacman --noconfirm -S docker docker-compose
# Docker Logfiles
pacman --noconfirm -S logrotate
logrotate_docker=/etc/logrotate.d/docker
cat >${logrotate_docker} <<EOF
/var/lib/docker/containers/*/*.log {
        rotate 30
        daily
        compress
        missingok
        delaycompress
        copytruncate
}
EOF
systemctl enable docker
systemctl start docker

#
# ZSH
#

pacman --noconfirm -S zsh
usermod -s /bin/zsh root

#
# Mikrokosmos Docker
#

MIKROKOSMOS_VERSION=v1.0

# Docker and SonarQube / Elasticsearch
cat >>/etc/sysctl.d/99-sysctl.conf <<EOF
vm.max_map_count=262144
EOF
sysctl --system

# Shallow clone Mikrokosmos Docker
#git config set advice.detachedHead false
if [ ! -d mikrokosmos-docker ]
then
    git clone \
        --depth 1 \
        --branch ${MIKROKOSMOS_VERSION} \
        https://github.com/artofcoding/mikrokosmos-docker.git
else
    pushd mikrokosmos-docker >/dev/null
    ./deploy.sh stop
    git reset --hard
    git pull
    popd >/dev/null
fi
pushd mikrokosmos-docker >/dev/null
echo ""
echo "* Please initialize or start Mikrokosmos Container yourself, depending on your needs:"
echo "* Go to $(pwd) and e.g."
echo "*     ./deploy.sh build-pm"
echo "*     ./deploy.sh build-cicd"
echo "*     ./deploy.sh init"
echo ""
popd >/dev/null

exit 0
