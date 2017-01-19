#!/bin/bash
# from  https://doc.owncloud.org/server/9.0/admin_manual/installation/installation_wizard.html?highlight=trusted#trusted-domains
ocpath=${ocpath:-'/var/www/nextcloud'}
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
find ${ocpath%/}/ -type f -print0 | xargs -0 chmod 0640
find ${ocpath%/}/ -type d -print0 | xargs -0 chmod 0750

printf "chown oc Directories\n"
chown -R ${rootuser}:${htgroup} ${ocpath%/}/
chown -R ${htuser}:${htgroup} ${ocpath%/}/apps/
#chown -R ${htuser}:${htgroup} ${ocpath%/}/apps2/
chown -R ${htuser}:${htgroup} ${ocpath%/}/config/
chown -R ${htuser}:${htgroup} ${datapath%/}/
chown -R ${htuser}:${htgroup} ${ocpath%/}/themes/

chmod +x ${ocpath%/}/occ

printf "chmod/chown .htaccess\n"
if [ -f ${ocpath%/}/.htaccess ]
then
    chmod 0644 ${ocpath%/}/.htaccess
    chown ${rootuser}:${htgroup} ${ocpath%/}/.htaccess
fi
if [ -f ${datapath}/.htaccess ]
then
    chmod 0644 ${datapath}/.htaccess
    chown ${rootuser}:${htgroup} ${datapath%/}/.htaccess
fi

echo "nextcloudStringDirectoryPermission : terminated"
