#!/bin/bash
OLD=`pwd`
cd `dirname $0`/Tetras-back
git pull
make dependencies
make
cd $OLD
