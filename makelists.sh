#!/bin/bash 
# --
# makelists.sh - a script to create multiple aliases
#
# Copyright (c) 2005, Rick Cogley
# <rick [at] esolia [dot] co [dot] jp>, eSolia Inc.
#
# This program is free software; you can redistribute it and/or modify 
# it under the terms of the GNU General Public License as published by 
# the Free Software Foundation; either version 2 of the License, or 
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, 
# but WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU General Public License for more details.
#
# Get the GNU General Public License from the Free Software 
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
# --

echo "makelists.sh - <\$Revision: 0.2 $>"
echo This script creates mailing lists based on user variables 
echo entered interactively and set with variables in the script. 
echo It is intended to help maintain consistency. 

# set global variables
MLALIASES=/etc/postfix/aliases
P1ALIASLIST=/etc/postfix/esolia-cellphonemail-01
MLADMINALIAS=mlsupport
TSALIAS=track
NEWALIASESCMD=/usr/bin/newaliases
NEWUSERCMD=/usr/sbin/useradd
PASSWDCMD=/usr/bin/passwd

echo
echo Get user input for variables...
while [ "$x" != "y" ]; do
  echo
  echo Enter a short name for the client, no spaces, LOWERcase:
  read CSN
  echo
  echo == SCRIPT PRESETS ==
  echo Aliases File to Write: $MLALIASES
  echo Support address for owner- and -request lists: $MLADMINALIAS
  echo Tracking System Alias: $TSALIAS
  echo List for Priority Cell Phone Mail: $P1ALIASLIST
  echo == USER ==
  echo Client Short Name: $CSN
  echo
  echo "Is this correct? (y/n)"
  read x
done

echo Create user...
THEUSER=$CSN-inbox
$NEWUSERCMD -m $THEUSER
echo eSolia2007 | $PASSWDCMD --stdin $THEUSER

echo
echo Writing aliases file and generating db...
echo
echo "# STANZA START: $CSN" >> $MLALIASES 
echo "# CREATED: `date`" >> $MLALIASES 
for i in support p1 
do 
    echo ===== Processing $CSN-$i =====
    echo
    echo Creating list: $CSN-$i
    if [ "$i" = "p1" ]
      then
        echo "$CSN-$i: $THEUSER,:include:$P1ALIASLIST" >> $MLALIASES 
        echo "owner-$CSN-$i: $MLADMINALIAS" >> $MLALIASES 
        echo "$CSN-$i-request: $MLADMINALIAS" >> $MLALIASES     
      else
        echo "$CSN-$i: $THEUSER" >> $MLALIASES 
        echo "owner-$CSN-$i: $MLADMINALIAS" >> $MLALIASES 
        echo "$CSN-$i-request: $MLADMINALIAS" >> $MLALIASES 
        echo 
    fi
done 
echo "# STANZA END: $CSN" >> $MLALIASES 
echo "" >> $MLALIASES
echo ======================== 
echo Activating lists...
$NEWALIASESCMD
echo
echo =========================
echo Lists Just Created: 
echo
cat $MLALIASES |grep $CSN
echo 
# cleanup

exit 0
