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
if [ -z `dpkg -l | grep dolibarr` ]
then
    echo "Dolibarr not installed, aborting"
    exit 1
fi
git pull
current_version=`apt-cache policy dolibarr | grep Installed | awk '{print $2}'`
echo "Current version of dolibarr: $current_version"
package=`/bin/ls DOLIBARR_PACKAGES/*.deb`
last_repo_version=`echo $package | sed 's/.*dolibarr_\([^_]*\)_.*/\1/'`
echo "Version of dolibarri on our repo: $current_version"
if [ "$current_version" == "$last_repo_version" ]
then
echo "Current version of dolibarr is the last version in our repo, nothing to do"
    exit
fi
echo "Installing $package"
dpkg -i $package
echo "Fixing dependencies"
apt-get -f install
echo "You should now be running Dolibarr version $current_version"
echo "Please check Dolibar webpage for possible manual upgrade steps"
