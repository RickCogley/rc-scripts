#!/bin/bash

# Convenience variables to specify volume to watch

backupVolume="/Volumes/Cogley\ Maxtor/"

# This sleep timer has been added to allow enough
# time for the system to mount the external drive

sleep 3

# This check is added to test for cases when we are
# removing a drive from /Volumes or if the drive failed
# to mount in the first place

if [! -d "$backupVolume" ]; then
 exit 0
fi

/Users/rcogley/Library/Application\ Support/SuperDuper\!/Scheduled\ Copies/SDUtil -i || open file:///Users/rcogley/Documents/\!SysAd/SuperDuper/Smart\ Update\ JRC-MBP-rcogley-20100128-01\ from\ Macintosh\ HD.sdsp/Copy\ Job.app

# Users/rcogley/Documents/!SysAd/SuperDuper/Smart\%20Update\%20JRC-MBP-rcogley-20100128-01\%20from\%20Macintosh\%20HD\%201.sdsp/Copy\%20Job.app

# Optionally, once the rsync is done, unmount the drive.

hdiutil detach $backupVolume

exit 0



# http://stackoverflow.com/questions/59838/how-to-check-if-a-directory-exists-in-a-bash-shell-script
# http://www.macresearch.org/tutorial_backups_with_launchd
