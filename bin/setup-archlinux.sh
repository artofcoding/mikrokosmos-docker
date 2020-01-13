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

# Shallow clone Mikrokosmos Docker
git config set advice.detachedHead false
if [ ! -d mikrokosmos-docker ]
then
    git clone --depth 1 \
        --branch ${MIKROKOSMOS_VERSION} \
        https://github.com/artofcoding/mikrokosmos-docker.git
fi
# Deploy
pushd mikrokosmos-docker >/dev/null
git reset --hard
git pull
./deploy.sh build
popd >/dev/null

exit 0
