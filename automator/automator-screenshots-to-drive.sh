#!/bin/bash
# Author: Rick Cogley
# Updated: 27 Jan 2016
# Purpose: For use in a Mac OS X automator action, set to watch a screenshot folder.
# Assumes:
#   GOPATH is set
#   drive is installed (https://github.com/odeke-em/drive)
#   there is a folder initialized with "drive init"

DRIVEINITPATH=$HOME/gdrive
GOPATH=$HOME/gocode
EXIFTOOLBIN=/usr/local/bin/exiftool
CURRYEAR=$(date +'%Y')
EXIFAUTHOR="Rick Cogley"
EXIFDISCLAIMER="All rights reserved."

cd $DRIVEINITPATH/Screenshots
ln -s "$1"
echo "$1" > out-originalpath.txt
fn=$(basename "$1")
echo "$fn" > out-filename.txt
descn="$(osascript -e 'Tell application "System Events" to display dialog "Enter the description:" default answer "Screenshot of "' -e 'text returned of result' 2>/dev/null)"
$EXIFTOOLBIN -artist="$EXIFAUTHOR" -author="$EXIFAUTHOR" -copyright="$CURRYEAR $EXIFAUTHOR" -disclaimer="$EXIFDISCLAIMER" -comment="$descn" -description="$descn" "$fn"
$GOPATH/bin/drive push --quiet "$fn"
$GOPATH/bin/drive pub "$fn"
$GOPATH/bin/drive edit-desc --description "$descn" "$fn"
$GOPATH/bin/drive url "$fn" | grep -o 'http*.*' | pbcopy

# REMINDERS
#  fn=`cat var.txt`
#  you can install exiftool via brew
#  capture on mac: cmd-shift-4
#  change screenshot file type: defaults write com.apple.screencapture type png
#  change screenshot file name: defaults write com.apple.screencapture name "JRC Screenshot"
#  make changes take effect: killall SystemUIServer
