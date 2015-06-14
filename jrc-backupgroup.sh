#!/bin/sh

# Setup vars
dt=`date '+%Y%m%d%H%M'`
targetext="$1"

for i in *.$targetext; { cp $i "${i%.$targetext}.$targetext.$dt"; }

exit 0
