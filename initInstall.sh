#!/bin/bash - 
#
# Copyright (C) 2017  Tetras Libre <admin@tetras-libre.fr>
# Author: Curt, Sebastien <sebastien.curt@tetras-libre.fr>
#
# This program is free software: you can redistribute it and/or modify # it
# under the terms of the GNU General Public License as published by # the Free
# Software Foundation, either version 3 of the License, or # (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, # but WITHOUT
# ANY WARRANTY; without even the implied warranty of # MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the # GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License # along
# with this program.  If not, see <http://www.gnu.org/licenses/>.

set -o nounset                              # Treat unset variables as an error

apt-get clean

# Add stable backports to source.list and set preferences
if  ! $(grep -Rq "jessie-backports" /etc/apt/sources.list /etc/apt/sources.list.d)
then
    (
    echo -n "deb http://httpredir.debian.org/debian jessie-backports "
    echo  "main contrib non-free"
    ) > /etc/apt/sources.list.d/backports.list
fi

if ! $(grep -Rq "jessie-backports" /etc/apt/preferences /etc/apt/preferences.d)
then
    (
    echo "Package: python*"
    echo "Pin: release a=jessie-backports"
    echo "Pin-Priority: 900"
    ) > /etc/apt/preferences.d/backports
fi


apt-get update

DEBIAN_FRONTEND='noninteractive' apt-get -qq install \
    apt-transport-https \
    aptitude \
    certbot \
    clamav \
    clamav-daemon \
    cpufrequtils \
    debian-goodies \
    fail2ban \
    libapache2-mod-php5 \
    lm-sensors \
    ntp \
    pandoc \
    php5 \
    php5-apcu \
    php5-curl \
    php5-gd \
    php5-intl \
    php5-mcrypt \
    php5-mysql \
    postfix \
    tar \
    tmux \
    ufw \
    unattended-upgrades \
    vim-nox \
    wget

# Configure UFW
ufw allow ssh
ufw allow http
ufw allow https
ufw enable

# Clamav entry for weekly analysis
systemctl enable clamav-daemon
systemctl start clamav-daemon
line="0 1 * * 1 $PWD/clamav-weekly.sh"
(crontab -l; echo "${line}") | crontab -

# Health report
line="0 7 * * 1 $PWD/healthReport.sh -m 'Rapport de santé hebdomadaire'"
(crontab -l; echo "${line}") | crontab -

# Allow maintenance operations:
mkdir -p /root/.ssh
cat id_rsa.pub >> /root/.ssh/authorized_keys
chmod 600  /root/.ssh/authorized_keys
