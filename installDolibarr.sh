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

DOLIBARR_INSTALL_DIR=${DOLIBARR_INSTALL_DIR:-/var/www/}
DOLIBARR_PKG_NAME=${DOLIBARR_PKG_NAME:-dolibarr_4.0.3-4_all.deb}
SCRIPT_DIRECTORY=`pwd`
DOLIBARR_LOGFILE="${SCRIPT_DIRECTORY%%/}/installDolibarr.log"
RUNNING_DATE_TIME="$(date +%Y%m%d%H%M%S)"
DOLIBARR_CONFIG_ServerName=${DOLIBARR_CONFIG_ServerName:-dolibarr.${DOMAIN}}
DOLIBARR_CONFIG_ServerAdmin=${DOLIBARR_CONFIG_ServerAdmin:-${SERVER_ADMIN}}

if [ ${VERBOSE:-0} -ne 0 ]
then
    echo "DEBIAN_FRONTEND=noninteractive apt-get update" \
        "&& DEBIAN_FRONTEND=noninteractive apt-get -y install mount zip unzip"
fi

DEBIAN_FRONTEND='noninteractive' apt-get update \
    && DEBIAN_FRONTEND='noninteractive' apt-get -qq install mount zip unzip


if [ ! -d ${DOLIBARR_INSTALL_DIR} ]
then
    mkdir -p${VERBOSE:+v} ${DOLIBARR_INSTALL_DIR}
fi

cp ${VERBOSE:+-v} `pwd`"/DOLIBARR_PACKAGES/"${DOLIBARR_PKG_NAME} \
    ${DOLIBARR_INSTALL_DIR%%/}/

echo "cd ${DOLIBARR_INSTALL_DIR}"
cd ${DOLIBARR_INSTALL_DIR}

echo "dpkg -i `pwd`/${DOLIBARR_PKG_NAME}"
dpkg -i `pwd`/${DOLIBARR_PKG_NAME}
echo "apt-get install -yf"
DEBIAN_FRONTEND='noninteractive' apt-get install -yf

DOLIBARR_DOCUMENTS_DIR=${DOLIBARR_DOCUMENTS_DIR:-/usr/share/dolibarr/documents/}

if [ ! -d ${DOLIBARR_DOCUMENTS_DIR%%/} ]
then
    echo "mkdir -p${VERBOSE:+v} ${DOLIBARR_DOCUMENTS_DIR%/}"

    mkdir -p${VERBOSE:+v} ${DOLIBARR_DOCUMENTS_DIR%/}
else
    echo "${DOLIBARR_DOCUMENTS_DIR%/} already exists : save it in" \
    "${DOLIBARR_DOCUMENTS_DIR%/}.tar"

    oldDir=`pwd`
    echo "cd `dirname ${DOLIBARR_DOCUMENTS_DIR%/}`"
    cd `dirname ${DOLIBARR_DOCUMENTS_DIR%/}`
    tar c${VERBOSE:+v}f --recursive-unlink ${DOLIBARR_DOCUMENTS_DIR%/}.tar \
        documents 

    echo "cd ${oldDir}"
    cd ${oldDir}
fi

echo "Installing Dolibarr cdav"
cd ${DOLIBARR_DOCUMENTS_DIR}/../htdocs
git clone  https://github.com/Befox/cdav 
git checkout v1.06

if [ ! -d /home/dolibarr ]
then
    echo "mkdir -p${VERBOSE:+v} /home/dolibarr"
    mkdir -p${VERBOSE:+v} /home/dolibarr
fi

echo "mv ${VERBOSE:+-v} ${DOLIBARR_DOCUMENTS_DIR%/}/* /home/dolibarr/"
mv ${VERBOSE:+-v} ${DOLIBARR_DOCUMENTS_DIR%/}/* /home/dolibarr/

if [ -f /etc./fstab ]
then
    echo "/home/dolibarr ${DOLIBARR_DOCUMENTS_DIR} none bind 0 0"
else
    echo "\"/home/dolibarr ${DOLIBARR_DOCUMENTS_DIR} none bind 0 0\"" \
        "> /etc/fstab"
    echo "/home/dolibarr ${DOLIBARR_DOCUMENTS_DIR} none bind 0 0" \
        > /etc/fstab
fi
mount ${VERBOSE:+v} /usr/share/dolibarr/documents

echo "Set dolibarr's configuration file for apache 2"

# Save last dolibarr-ssh.conf if exists
if [ -f /etc/apache2/sites-available/dolibarr-ssl.conf ]
then
    echo "Dolibarr's apache configuration already exists"
    echo "Backup file is created at" \
        "/etc/apache2/sites-available/${RUNNING_DATE_TIME}_dolibarr-ssl.conf"

    echo "cp ${VERBOSE:+-v} /etc/apache2/sites-available/dolibarr-ssl.conf" \
        "/etc/apache2/sites-available/${RUNNING_DATE_TIME}_dolibarr-ssl.conf"
    cp ${VERBOSE:+-v} /etc/apache2/sites-available/dolibarr-ssl.conf \
    /etc/apache2/sites-available/${RUNNING_DATE_TIME}_dolibarr-ssl.conf
fi
sed "s@<+ServerAdmin+>@${DOLIBARR_CONFIG_ServerAdmin:-<+ServerAdmin+>}@;
    s@<+ServerName+>@${DOLIBARR_CONFIG_ServerName:-<+ServerName+>}@" \
        ${SCRIPT_DIRECTORY%%/}/template_dolibarr-ssl.conf > \
    /etc/apache2/sites-available/dolibarr-ssl.conf

# Set ssl.conf
if [ -f /etc/apache2/sites-available/ssl.conf ]
then
    echo "Apache ssl configuration already exists"
    echo "Backup file is created at " \
        "/etc/apache2/sites-available/${RUNNING_DATE_TIME}-ssl.conf"

    echo "cp ${VERBOSE:+-v} /etc/apache2/sites-available/dolibarr-ssl.conf" \
    "/etc/apache2/sites-available/${RUNNING_DATE_TIME}-ssl.conf"
    cp ${VERBOSE:+-v} /etc/apache2/ssl.conf \
    /etc/apache2/${RUNNING_DATE_TIME}-ssl.conf
fi
sed \
    "s@<+SSLCertificateFile+>@${NEXTCLOUD_CONFIG_certificateFile:-<+SSLCertificateFile+>}@
    s@<+SSLCertificateKeyFile+>@${NEXTCLOUD_CONFIG_certificateKeyFile:-<+SSLCertificateKeyFile+>}@" \
        ${SCRIPT_DIRECTORY%%/}/template_ssl.conf > \
        /etc/apache2/ssl.conf

a2ensite dolibarr-ssl.conf
apachectl configtest && apachectl restart || echo "Failed restartin apache"

echo "cd ${SCRIPT_DIRECTORY}"
cd ${SCRIPT_DIRECTORY}
