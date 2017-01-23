#!/bin/bash
NEXTCLOUD_INSTALL_DIR=${NEXTCLOUD_INSTALL_DIR:-'/var/www/nextcloud'}
NEXTCLOUD_INSTALL_DIR=`echo $NEXTCLOUD_INSTALL_DIR | sed 's@/*$@@'`
htuser=${htuser:-'www-data'}
ocupdater=${ocupdater:-"$NEXTCLOUD_INSTALL_DIR/updater/updater.phar"}
occ=$NEXTCLOUD_INSTALL_DIR/occ
APPS=`sudo -u $htuser php $occ app:list | awk 'BEGIN{ok=1} /^Disabled:/{ok=0} {if(ok==1){print $2}}' | sed 's/:$//'`
echo "Removing old backup"
rm -rf $NEXTCLOUD_INSTALL_DIR.bak
echo "backing up nextcloud"
cp -r $NEXTCLOUD_INSTALL_DIR $NEXTCLOUD_INSTALL_DIR.bak
echo "Entering maintenance mode"
sudo -u $htuser php $occ maintenance:mode --on
echo "Giving all permissions to $htuser"
chown -R $htuser: $NEXTCLOUD_INSTALL_DIR
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


