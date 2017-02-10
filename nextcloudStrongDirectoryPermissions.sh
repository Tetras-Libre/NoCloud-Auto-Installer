#!/bin/bash

# Copyright (C) 2017  Tetras Libre <admin@tetras-libre.fr>
# Author: Curt, Sebastien <Sebastien.Curt@tetras-libre.fr>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# from  https://doc.owncloud.org/server/9.0/admin_manual/installation/installation_wizard.html?highlight=trusted#trusted-domains
NEXTCLOUD_INSTALL_DIR=${NEXTCLOUD_INSTALL_DIR:-'/var/www/nextcloud'}
htuser=${htuser:-'www-data'}
htgroup=${htgroup:-'www-data'}
rootuser=${rootuser:-'root'}
datapath=${datapath:-'/home/nextcloud'}

echo "nextcloudStringDirectoryPermission"

printf "Creating possible missing Directories\n"
if [ ! -d ${datapath%/} ]
then
    mkdir -p ${datapath%/}
fi

printf "chmod Files and Directories\n"
find ${NEXTCLOUD_INSTALL_DIR%/}/ -type f -print0 | xargs -0 chmod 0640
find ${NEXTCLOUD_INSTALL_DIR%/}/ -type d -print0 | xargs -0 chmod 0750

printf "chown oc Directories\n"
chown -R ${rootuser}:${htgroup} ${NEXTCLOUD_INSTALL_DIR%/}/
chown -R ${htuser}:${htgroup} ${NEXTCLOUD_INSTALL_DIR%/}/apps/
#chown -R ${htuser}:${htgroup} ${NEXTCLOUD_INSTALL_DIR%/}/apps2/
chown -R ${htuser}:${htgroup} ${NEXTCLOUD_INSTALL_DIR%/}/config/
chown -R ${htuser}:${htgroup} ${datapath%/}/
chown -R ${htuser}:${htgroup} ${NEXTCLOUD_INSTALL_DIR%/}/themes/

chmod +x ${NEXTCLOUD_INSTALL_DIR%/}/occ

printf "chmod/chown .htaccess\n"
if [ -f ${NEXTCLOUD_INSTALL_DIR%/}/.htaccess ]
then
    chmod 0644 ${NEXTCLOUD_INSTALL_DIR%/}/.htaccess
    chown ${rootuser}:${htgroup} ${NEXTCLOUD_INSTALL_DIR%/}/.htaccess
fi
if [ -f ${datapath}/.htaccess ]
then
    chmod 0644 ${datapath}/.htaccess
    chown ${rootuser}:${htgroup} ${datapath%/}/.htaccess
fi

echo "nextcloudStringDirectoryPermission : terminated"
