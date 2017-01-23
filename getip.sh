#!/bin/bash
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

