#!/bin/sh
echo "mm-multi.sh - <\$Revision: 0.1 $>"

# set global variables
MMBIN=/usr/lib/mailman/bin
MMALIASES=/etc/mailman
MMLISTLANG=en
MMOWNEREMAIL=rick.cogley@esolia.co.jp
MMADMINPASS=mm2005!
MMLISTTMPLFILE=/rcutils/scripts/mailman-template01.in
MMDMEMBERS=/tmp/mm-multi-defaultmembers
MMSMEMBERS=/tmp/mm-multi-smsmembers
echo track@esolia.net >$MMDMEMBERS
echo rick.cogley@ezweb.ne.jp >$MMSMEMBERS
MMTMP=/tmp

echo
echo Creating lists based on a structure...
while [ "$x" != "y" ]; do
  echo
  echo Enter a short name for the client, no spaces, lowercase:
  read CSHORTNAME
  echo 
  echo == SCRIPT PRESETS ==
  echo Location of Mailman scripts: $MMBIN
  echo Location of Mailman aliases: $MMALIASES
  echo List language: $MMLISTLANG
  echo List Owner Email: $MMOWNEREMAIL
  echo List Admin Password: $MMADMINPASS
  echo
  echo == USER ==
  echo Client Short Name: $CSHORTNAME
  echo
  echo "Is this correct? (y/n)"
  read x
done

# touch /tmp/mm-multi-$CSHORTNAME-sales-tmp
# $CSHORTNAME-sales-tmp=/tmp/mm-multi-$CSHORTNAME-sales-tmp
echo description = '$CSHORTNAME-sales' 
echo "description = '$CSHORTNAME-sales'"  >/tmp/mm-multi-$CSHORTNAME-sales-tmp
echo available_languages = ['en', 'ja']
echo "available_languages = ['en', 'ja']" >>/tmp/mm-multi-$CSHORTNAME-sales-tmp
echo accept_these_nonmembers = ['^[^@]+@(.+\\.|)esolia\\.co\\.jp$', '^[^@]+@(.+\\.|)gmail\\.com$']
echo "accept_these_nonmembers = ['^[^@]+@(.+\\\.|)esolia\\\.co\\\.jp$', '^[^@]+@(.+\\\.|)gmail\\\.com$']" >>/tmp/mm-multi-$CSHORTNAME-sales-tmp
cat /tmp/mm-multi-$CSHORTNAME-sales-tmp 


