#!/bin/bash
OLD=`pwd`
DIR=$DIR
if [ ! -d $DIR ]
then
    echo "Tetras-back not installed, aborting"
    exit 1
fi
cd $DIR
git pull
make dependencies
make
cd $OLD
