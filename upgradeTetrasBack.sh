#!/bin/bash
cd `dirname $0`/Tetras-back
git pull
make dependencies
make
