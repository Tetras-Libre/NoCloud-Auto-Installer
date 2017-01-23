#!/bin/bash
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
