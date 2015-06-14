#! /bin/bash
# run logwatch against all archived logs

/usr/share/logwatch/scripts/logwatch.pl --output html-embed --range All --archives --detail High

exit 0
