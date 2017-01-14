#!/bin/bash - 
#===============================================================================
#
#          FILE: InitInstall.sh
# 
#         USAGE: ./InitInstall.sh 
# 
#   DESCRIPTION: Configure and update apt-get :
#                    -- Add jessie backport to APT source list
#                    -- Set the APT for php* backports sources higher than
#                    the source from jessie
#                    -- Install required apps
# 
#       OPTIONS: ---
#  REQUIREMENTS: --- apt-get shall be installed
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: SEBASTIEN CURT (), sebastien.curt@tetras-libre.fr
#  ORGANIZATION: 
#       CREATED: 01/12/2017 09:42:33
#      REVISION:  0.0.1
#===============================================================================

set -o nounset                              # Treat unset variables as an error

apt-get clean

if  ! $(grep -Rq "jessie-backports" /etc/apt/sources.list /etc/apt/sources.list.d)
then
    (
    echo -n "deb http://httpredir.debian.org/debian jessie-backports "
    echo  "main contrib non-free"
    ) > /etc/apt/sources.list.d/backports.list
fi

if ! $(grep -Rq "jessie-backports" /etc/apt/preferences /etc/apt/preferences.d)
then
    (
    echo "Package: python*"
    echo "Pin: release a=jessie-backports"
    echo "Pin-Priority: 900"
    ) > /etc/apt/preferences.d/backports
fi

apt-get update

DEBIAN_FRONTEND='noninteractive' apt-get -qq install \
    tmux debian-goodies php5 fail2ban vim-nox certbot apt-transport-https \
    unattended-upgrades tar php5-gd php5-curl php5-intl php5-mcrypt \
    php5-mysql php5-apcu wget libapache2-mod-php5 postfix

