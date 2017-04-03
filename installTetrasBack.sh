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
    && DEBIAN_FRONTEND="noninteractive" apt-get -qq install git gnulib perl sendmail \
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

echo "Set tetras-back's configuration file for ${WEB_SERVER}"

# Save last tetras-back-ssh.conf if exists
if [ -f /etc/${WEB_SERVER}/sites-available/tetras-back.conf ]
then
    echo "Dolibarr's apache configuration already exists"
    echo "Backup file is created at" \
        "/etc/${WEB_SERVER}/sites-available/${RUNNING_DATE_TIME}_tetras-back.conf"

    echo "cp ${VERBOSE:+-v} /etc/${WEB_SERVER}/sites-available/tetras-back.conf" \
        "/etc/${WEB_SERVER}/sites-available/${RUNNING_DATE_TIME}_tetras-back.conf"
    cp ${VERBOSE:+-v} /etc/${WEB_SERVER}/sites-available/tetras-back.conf \
    /etc/${WEB_SERVER}/sites-available/${RUNNING_DATE_TIME}_tetras-back.conf
fi
sed "s@<+ServerAdmin+>@${DOLIBARR_CONFIG_ServerAdmin:-<+ServerAdmin+>}@;
    s@<+ServerName+>@${DOLIBARR_CONFIG_ServerName:-<+ServerName+>}@" \
        `pwd`/etc/${WEB_SERVER}/sites-available/tetras-back.conf > \
    /etc/${WEB_SERVER}/sites-available/tetras-back.conf

if [ ${WEB_SERVER} == "apache2" ]
then
    a2ensite tetras-back.conf
    apachectl configtest && apachectl restart || echo "Failed restartin apache"
else
    ln -s /etc/nginx/sites-available/tetras-back.conf /etc/nginx/sites-enabled
    systemctl restart nginx
fi
