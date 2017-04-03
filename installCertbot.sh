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

DOMAINS="dolibarr.${DOMAIN},nextcloud.${DOMAIN},tetras-back.${DOMAIN}"
ARGS="--hsts --must-staple --agree-tos --email=${SERVER_ADMIN} --domains=${DOMAINS}"
line="0 1 `date +%d` */2 * /usr/bin/certbot renew --force-renewal"
if [ ${WEB_SERVER} == "apache2" ]
then
    OPTS="run --apache"
    line+="${RENEW}"
else
    OPTS="certonly --standalone"
    EXTRA_ARGS="--pre-hook \"systemctl stop nginx\" --post-hook \"systemctl start nginx\""
fi
/usr/bin/certbot ${OPTS} ${ARGS} ${EXTRA_ARGS}
line+=" ${EXTRA_ARGS} > /dev/null"
(crontab -l; echo "${line}") | crontab -
