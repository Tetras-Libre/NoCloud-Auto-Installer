#!/bin/bash

# Copyright (C) 2017  Tetras Libre <admin@tetras-libre.fr>
# Author: Beniamine, David <David@Beniamine.net>
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

isIP()
{
    ret=1
    ip=$1
    if [[ $ip=~^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
    then
        OIFS=$IFS
        IFS='.'
        ip=($1)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        ret=$?

    fi
    return $ret
}
Hosts=("icanhazip.com" "ident.me" "ipecho.net/plain" \
    "whatismyip.akamai.com" "tnx.nl/ip" "myip.dnsomatic.com" \
    "ip.appspot.com" "ip.telize.com" "curlmyip.com" "ifconfig.me" )
for h in ${Hosts[@]}
do
    myip=$(curl -s $h)
    if isIP $myip
    then
        echo "External IP is : $myip"
        exit 0
    fi
done

