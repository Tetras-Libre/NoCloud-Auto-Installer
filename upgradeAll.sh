#!/bin/bash
DIR=`dirname $0`
. $DIR/installNextcloud.env
. $DIR/upgradeNextcloud.sh
. $DIR/upgradeTetrasBack.sh
. $DIR/upgradeDolibarr.sh
