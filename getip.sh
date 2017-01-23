#!/bin/bash
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

