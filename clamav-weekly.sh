#!/bin/bash
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
