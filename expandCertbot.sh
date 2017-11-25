#!/bin/bash
if [ -z "$2" ]
then
	echo "usage $0 additional-dommains certificate"
	echo "additional-domains : comma separated list of domains"
	echo "expand the existing certificate with the given domains"
	exit 1
fi
domains="`openssl x509  -in $2 -inform pem -noout -text | grep DNS | sed -e 's/  *//g' -e 's/DNS://g'`,$1"

echo "Requesting certificate for domains: '$domains'"
certbot certonly --expand --apache --must-staple --hsts --domains=$domains

