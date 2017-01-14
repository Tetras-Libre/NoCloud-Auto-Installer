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

if [ -f installDolibarr.env ]
then
    . `pwd`/installDolibarr.env
fi

DOLIBARR_INSTALL_DIR=${DOLIBARR_INSTALL_DIR:-/var/www}
DOLIBARR_PKG_NAME=${DOLIBARR_PKG_NAME:-dolibarr_4.0.3-4_all.deb}
SCRIPT_DIRECTORY=`pwd`

apt-get update && apt-get install mount

if [ ! -d ${DOLIBARR_INSTALL_DIR} ]
then
    mkdir -p ${DOLIBARR_INSTALL_DIR}
fi

cp `pwd`"/DOLIBARR_PACKAGES/"${DOLIBARR_PKG_NAME} ${DOLIBARR_INSTALL_DIR%%/}/
cd ${DOLIBARR_INSTALL_DIR}

dpkg -i `pwd`/${DOLIBARR_PKG_NAME}
apt-get install -f

DOLIBARR_DOCUMENTS_DIR=${DOLIBARR_DOCUMENTS_DIR:-/usr/share/dolibarr/documents/}

if [ ! -d ${DOLIBARR_DOCUMENTS_DIR%/} ]
then
    mkdir -p ${DOLIBARR_DOCUMENTS_DIR%/}

else
    echo "${DOLIBARR_DOCUMENTS_DIR%/} already exists : save it in" \
    "${DOLIBARR_DOCUMENTS_DIR%/}.tar"
    oldDir=`pwd`
    cd `dirname ${DOLIBARR_DOCUMENTS_DIR%/}`
    tar cf --recursive-unlink ${DOLIBARR_DOCUMENTS_DIR%/}.tar documents 
    cd ${oldDir}
fi

if [ ! -d /home/dolibarr ]
then
    mkdir -p /home/dolibarr
fi

mv ${DOLIBARR_DOCUMENTS_DIR%/}/* /home/dolibarr/

if [ -f /etc./fstab ]
then
    echo "/home/dolibarr  /usr/share/dolibarr/documents none bind 0 0" \
        >> /etc/fstab
fi
mount /usr/share/dolibarr/documents


cd ${SCRIPT_DIRECTORY}
