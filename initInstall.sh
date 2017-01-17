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
    tmux debian-goodies php5 fail2ban vim-nox certbot apt-transport-https \
    unattended-upgrades tar php5-gd php5-curl php5-intl php5-mcrypt \
    php5-mysql php5-apcu wget libapache2-mod-php5 postfix

