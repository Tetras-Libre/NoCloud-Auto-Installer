#!/bin/bash - 
#
# Copyright (C) 2017  Tetras Libre <admin@tetras-libre.fr>
# Author: Beniamine, David <david.beniamine@tetras-libre.fr>
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


. `pwd`/main.env

apt-get update && apt-get install certbot

DOMAINS="dolibarr.${DOMAIN},nextcloud.${DOMAIN},tetras-back.${DOMAIN}"
ARGS="--hsts --must-staple --email=${SERVER_ADMIN} --domains=${DOMAINS}
    --text --agree-tos"
line="0 1 `date +%d` */2 * /usr/bin/certbot renew --force-renewal"
if [ "${WEB_SERVER}" == "apache2" ]
then
    additional_packages="python-certbot-apache"
    OPTS="run --apache"
    line+="${RENEW}"
else
    OPTS="certonly --standalone"
    precmd="systemctl stop nginx"
    postcmd="systemctl start nginx"
    EXTRA_ARGS="--pre-hook \"$precmd\" --post-hook \"$postcmd\""
fi

DEBIAN_FRONTEND='noninteractive' apt-get -qq install \
    certbot ${additional_packages}

$precmd
/usr/bin/certbot ${OPTS} ${ARGS}
$postcmd
line+=" ${EXTRA_ARGS} > /dev/null"
(crontab -l; echo "${line}") | crontab -
