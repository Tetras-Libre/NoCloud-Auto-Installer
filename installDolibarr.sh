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
SCRIPT_DIRECTORY=`pwd`
DOLIBARR_PKG_NAME=`ls ${SCRIPT_DIRECTORY%%/}/DOLIBARR_PACKAGES`
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
    && DEBIAN_FRONTEND='noninteractive' apt-get -qq install mount zip unzip apg


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

echo "Set dolibarr's configuration file for ${WEB_SERVER}"

# Save last dolibarr-ssh.conf if exists
if [ -f /etc/${WEB_SERVER}/sites-available/dolibarr-ssl.conf ]
then
    echo "Dolibarr's ${WEB_SERVER} configuration already exists"
    echo "Backup file is created at" \
        "/etc/${WEB_SERVER}/sites-available/${RUNNING_DATE_TIME}_dolibarr-ssl.conf"

    echo "cp ${VERBOSE:+-v} /etc/${WEB_SERVER}/sites-available/dolibarr-ssl.conf" \
        "/etc/${WEB_SERVER}/sites-available/${RUNNING_DATE_TIME}_dolibarr-ssl.conf"
    cp ${VERBOSE:+-v} /etc/${WEB_SERVER}/sites-available/dolibarr-ssl.conf \
    /etc/${WEB_SERVER}/sites-available/${RUNNING_DATE_TIME}_dolibarr-ssl.conf
fi
sed "s/<+ServerAdmin+>/${DOLIBARR_CONFIG_ServerAdmin}/;
    s/<+ServerName+>/${DOLIBARR_CONFIG_ServerName}/" \
        ${SCRIPT_DIRECTORY%%/}/etc/${WEB_SERVER}/sites-available/dolibarr-ssl.conf > \
    /etc/${WEB_SERVER}/sites-available/dolibarr-ssl.conf

# Set ssl.conf
if [ -f /etc/${WEB_SERVER}/sites-available/ssl.conf ]
then
    echo "${WEB_SERVER} ssl configuration already exists"
    echo "Backup file is created at " \
        "/etc/${WEB_SERVER}/sites-available/${RUNNING_DATE_TIME}-ssl.conf"

    echo "cp ${VERBOSE:+-v} /etc/${WEB_SERVER}/sites-available/dolibarr-ssl.conf" \
    "/etc/${WEB_SERVER}/sites-available/${RUNNING_DATE_TIME}-ssl.conf"
    cp ${VERBOSE:+-v} /etc/${WEB_SERVER}/ssl.conf \
    /etc/${WEB_SERVER}/${RUNNING_DATE_TIME}-ssl.conf
fi
sed \
    "s@<+SSLCertificateFile+>@${NEXTCLOUD_CONFIG_certificateFile:-<+SSLCertificateFile+>}@
    s@<+SSLCertificateKeyFile+>@${NEXTCLOUD_CONFIG_certificateKeyFile:-<+SSLCertificateKeyFile+>}@" \
        ${SCRIPT_DIRECTORY%%/}/etc/${WEB_SERVER}/sites-available/ssl.conf > \
        /etc/${WEB_SERVER}/ssl.conf

if [ ${WEB_SERVER} == "apache2" ]
then
    a2ensite dolibarr-ssl.conf
    apachectl configtest && apachectl restart || echo "Failed restartin apache"
else
    ln -s /etc/nginx/sites-available/dolibarr-ssl.conf /etc/nginx/sites-enabled
    systemctl restart nginx
fi

# Create dolibar database in mysql
echo "create dolibarr database"
echo "mysql -e 'CREATE DATABASE dolibarr;'"
mysql -e 'CREATE DATABASE dolibarr;'
echo "Dolibarr database created"

echo "Create dolibarr Password for dolibarr database"
dolibarrPassword=${NEXTCLOUD_DATABASE_PASS:-"$(apg -q -a 0 -n 1 -m 21 -M NCL)"}

echo "Create admin Password for dolibarr"
adminPassword=${NEXTCLOUD_ADMIN_PASS=-"$(apg -q -a 0 -n 1 -m 21 -M NCL)"}
{
    echo "[dolibarr]"
    echo "user=admin"
    echo "password=${adminPassword}"
} >> ${HOME}/.passwords
chmod 600 ${HOME}/.passwords
echo "amdin user password store in ${HOME}/.passwords only" \
    "readable by the root user"

echo "Set dolibarr user for dolibarr@localhost in database"
mysql -e "CREATE USER 'dolibarr'@'localhost' IDENTIFIED BY
'${dolibarrPassword}';"
if [ $? -eq 0 ]
then
    echo "dolibarr user set for dolibarr@localhost in database"
else
    echo "error processing : $?" >&2
fi

echo "Grant all privileges to nexcloud user to dolibarr database"
mysql -e "GRANT ALL PRIVILEGES on dolibarr.* to
'dolibarr'@'localhost' IDENTIFIED BY '${dolibarrPassword}';
FLUSH PRIVILEGES;";
if [ $? -eq 0 ]
then
    echo "Privileges granted"
else
    echo "Error processing : $?" >&2
fi

{
    echo "[dolibarr-mysql]"
    echo "user=dolibarr"
    echo "password=${dolibarrPassword}"
} >> ${HOME}/.passwords

echo "cd ${SCRIPT_DIRECTORY}"
cd ${SCRIPT_DIRECTORY}


