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


LOGFILE="/tmp/clamav-$(date +'%Y-%m-%d').log";
EMAIL_TO="root";
DIRTOSCAN="/var/www /home";

do_sendmail(){
    message+="\n\n==== LOG  ====\n\n"
    while read line 
    do
        message+="$line\n"
    done < $LOGFILE
    (echo "Subject: [NoCloud ClamAv] $subject";
    echo "To: $EMAIL_TO";
    echo "Content-Type: text/plain; charset=UTF-8";
    echo "";
    echo -e "${message}") | sendmail -t
}

for S in ${DIRTOSCAN}; do
    DIRSIZE=$(du -sh "$S" 2>/dev/null | cut -f1);

    echo "Demarrage du scan hebdomadaire pour le repertoire: '$S'. Quantité de données à analyser : '$DIRSIZE'";

    clamscan -ri "$S" >> $LOGFILE

    # get the value of "Infected lines"
    MALWARE=$(tail "$LOGFILE"|grep Infected|cut -d" " -f3);

done

if [ $MALWARE -ne 0 ]
then
    subject="Menace detectée"
    message="Une menace a été detecté sur votre serveur.\n Merci de vous
    référer au log ci dessous et si besoin de contacter vos
    administrateur.rice système."
else
    subject="Aucune menace detectée"
    message="Aucune menace detectée durant l'analyse hebdomadaire de votre serveur."
fi

do_sendmail
rm $LOGFILE
