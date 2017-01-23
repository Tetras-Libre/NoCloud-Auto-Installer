#!/bin/bash
DIR=`dirname $0`
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
