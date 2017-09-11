#!/bin/bash

# Copyright (C) 2017  Tetras Libre <admin@tetras-libre.fr>
# Author: Beniamine, David <David.Beniamine@tetras-libre.fr>
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

NEXTCLOUD_INSTALL_DIR=${NEXTCLOUD_INSTALL_DIR:-'/var/www/nextcloud'}
NEXTCLOUD_INSTALL_DIR=`echo $NEXTCLOUD_INSTALL_DIR | sed 's@/*$@@'`
htuser=${htuser:-'www-data'}
ocupdater=${ocupdater:-"$NEXTCLOUD_INSTALL_DIR/updater/updater.phar"}
occ=$NEXTCLOUD_INSTALL_DIR/occ
APPS=`sudo -u $htuser php $occ app:list | awk 'BEGIN{ok=1} /^Disabled:/{ok=0} {if(ok==1){print $2}}' | sed 's/:$//'`

if [ ! -d $NEXTCLOUD_INSTALL_DIR ]
then
    echo "Nextcloud is not installed, aborting"
    exit 1
fi

if [ -z $MAINTENANCE_LEVEL ]
then
    echo "Maintenance level cannot be detected, please update your main.env"
    exit 1
fi

current_vesion=`sudo -u www-data php /var/www/nextcloud/occ status \
    | awk '/versionstring/{print $3}'`
echo "Nextclous is installed, version $current_vesion"
if [ $MAINTENANCE_LEVEL == "upgrade" ]
then
    echo "Checking version  from changelog page (upgrade)"
    target_version=`curl -silent https://nextcloud.com/changelog/ \
        | sed 's/>/>\n/g' | awk '/^<h3 id=/{print $2}' | head -n 1 \
        | sed -e 's/id="\(.*\)">/\1/' -e 's/-/./g'`
else
    echo "Checking version  from install page (security)"
    target_version=`curl -silent \
        'https://nextcloud.com/install/#instructions-server' \
        | sed 's/>/>\n/g'  | awk '/href=.*server\/release/{print $0}' \
        | head -n 1 | sed 's/.*nextcloud-\(.*\).zip">/\1/'`
fi

echo "Upstream version is : $target_version"

if [ "$current_vesion" == "$target_version" ]
then
    echo "Nextcloud is already up to date"
    exit 0
fi

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
echo "Removing backup htaccess file"
rm $NEXTCLOUD_INSTALL_DIR/.htaccess.bak

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


