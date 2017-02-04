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


TB_CONFIG_ServerName=${DOLIBARR_CONFIG_ServerName:-tetras-back.${DOMAIN}}
TB_CONFIG_ServerAdmin=${DOLIBARR_CONFIG_ServerAdmin:-${SERVER_ADMIN}}

set -o nounset                              # Treat unset variables as an error

DEBIAN_FRONTEND='noninteractive' apt-get update \
    DEBIAN_FRONTEND="noninteractive" apt-get -qq install git gnulib perl sendmail \
    udev systemd

SCRIPT_DIRECTORY=`pwd`

cd `dirname $0`
git clone https://gitlab.tetras-libre.fr/tetras-libre/Tetras-back.git
cd Tetras-back
export DEBIAN_FRONTEND="noninteractive"
make dependencies
make
unset DEBIAN_FRONTEND

cd $SCRIPT_DIRECTORY

echo "Set tetras-back's configuration file for apache 2"

# Save last tetras-back-ssh.conf if exists
if [ -f /etc/apache2/sites-available/tetras-back-ssl.conf ]
then
    echo "Dolibarr's apache configuration already exists"
    echo "Backup file is created at" \
        "/etc/apache2/sites-available/${RUNNING_DATE_TIME}_tetras-back-ssl.conf"

    echo "cp ${VERBOSE:+-v} /etc/apache2/sites-available/tetras-back-ssl.conf" \
        "/etc/apache2/sites-available/${RUNNING_DATE_TIME}_tetras-back-ssl.conf"
    cp ${VERBOSE:+-v} /etc/apache2/sites-available/tetras-back-ssl.conf \
    /etc/apache2/sites-available/${RUNNING_DATE_TIME}_tetras-back-ssl.conf
fi
sed "s@<+ServerAdmin+>@${DOLIBARR_CONFIG_ServerAdmin:-<+ServerAdmin+>}@;
    s@<+ServerName+>@${DOLIBARR_CONFIG_ServerName:-<+ServerName+>}@" \
        `pwd`/template_tetras-back-ssl.conf > \
    /etc/apache2/sites-available/tetras-back-ssl.conf

# Set ssl.conf
if [ -f /etc/apache2/sites-available/ssl.conf ]
then
    echo "Apache ssl configuration already exists"
    echo "Backup file is created at " \
        "/etc/apache2/sites-available/${RUNNING_DATE_TIME}-ssl.conf"

    echo "cp ${VERBOSE:+-v} /etc/apache2/sites-available/tetras-back-ssl.conf" \
    "/etc/apache2/sites-available/${RUNNING_DATE_TIME}-ssl.conf"
    cp ${VERBOSE:+-v} /etc/apache2/ssl.conf \
    /etc/apache2/${RUNNING_DATE_TIME}-ssl.conf
fi
sed \
    "s@<+SSLCertificateFile+>@${NEXTCLOUD_CONFIG_certificateFile:-<+SSLCertificateFile+>}@
    s@<+SSLCertificateKeyFile+>@${NEXTCLOUD_CONFIG_certificateKeyFile:-<+SSLCertificateKeyFile+>}@" \
        ${SCRIPT_DIRECTORY%%/}/template_ssl.conf > \
        /etc/apache2/ssl.conf

a2ensite tetras-back-ssl.conf
apachectl configtest && apachectl restart || echo "Failed restartin apache"
