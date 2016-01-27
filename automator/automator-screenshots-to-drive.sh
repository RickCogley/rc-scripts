#!/bin/bash
# Author: Rick Cogley
# Updated: 27 Jan 2016
# Purpose: For use in a Mac OS X automator action, set to watch a screenshot folder.
# Assumes:
#   GOPATH is set
#   drive is installed (https://github.com/odeke-em/drive)
#   there is a folder initialized with "drive init"

DRIVEINITPATH=$HOME/gdrive

cd $DRIVEINITPATH/Screenshots
ln -s "$1"
echo "$1" > out-originalpath.txt
fn=$(basename "$1")
echo "$fn" >> out-filename.txt
$GOPATH/bin/drive push --quiet "$fn"
$GOPATH/bin/drive pub "$fn"
$GOPATH/bin/drive url "$fn" | grep -o 'http*.*' | pbcopy

# Alternative
#  n=`cat var.txt`
