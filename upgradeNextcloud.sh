#!/bin/bash
ocpath=${ocpath:-'/var/www/nextcloud'}
htuser=${htuser:-'www-data'}
ocupdater=${ocupdater:-"$ocpath/updater/updater.phar"}
occ=$ocpath/occ
APPS=`sudo -u $htuser php $occ app:list | awk 'BEGIN{ok=1} /^Disabled:/{ok=0} {if(ok==1){print $2}}' | sed 's/:$//'`
echo "Removing old backup"
rm -rf $ocpath.bak
echo "backing up nextcloud"
cp -r $ocpath $ocpath.bak
echo "Entering maintenance mode"
sudo -u $htuser php $occ maintenance:mode --on
echo "Giving all permissions to $htuser"
chown -R $htuser: $ocpath
sudo -u $htuser php $ocupdater --no-interaction --verbose
sudo -u $htuser php $occ maintenance:mode --off

. `dirname $0`/nextcloudStrongDirectoryPermissions.sh
FAILED=""
for app in $APPS
do
    sudo -u $htuser php $occ app:enable $app
    if [ $? -ne 0 ]
    then
        FAILED+=" $app"
    fi
done
echo "Done"
if [ "$FAILED" != "" ]
then
    echo "Failed to enable some apps: '$FAILED'"
fi
echo "Please check difference between old and new .htaccess file"


