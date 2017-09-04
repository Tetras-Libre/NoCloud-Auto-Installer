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

DIR=`dirname $0`
. $DIR/main.env
. $DIR/installNextcloud.env
if [ -z "$MODS" ] || [ -z "$MAINTENANCE_LEVEL" ]
then
    echo "Please update your main.env"
    exit 1
fi
aptitude update
if [ "$MAINTENANCE_LEVEL" == "upgrade" ]
then
    aptitude upgrade
else
    unattended-upgrade
fi
for mod in $MODS
do
    script="$DIR/upgrade$mod.sh"
    if [ -f $script ]
    then
        . $script
    fi
done
services="`checkrestart | awk '/^service/{print $2} /^systemctl/{print $3}'` \
    $EXTRAS_SERVICES_TO_RESTART"
[ ! -z "$services" ] && systemctl restart $services
checkrestart
