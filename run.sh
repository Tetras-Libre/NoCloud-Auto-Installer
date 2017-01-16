#!/bin/bash - 
#
# Copyright (C) 2017  Tetras Libre <admin@tetras-libre.fr>
# Author: Curt, Sebastien <sebastien.curt@tetras-libre.fr>
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

set -o nounset                              # Treat unset variables as an error

if [ -f initInstall.sh ]
then
    . `pwd`/initInstall.sh
fi

if [ -f installMySQL.sh ]
then
    . `pwd`/installMySQL.sh
fi

if [ -f installNextcloud.sh ]
then
    . `pwd`/installNextcloud.sh
fi

if [ -f installDolibarr.sh ]
then
    . `pwd`/installDolibarr.sh
fi