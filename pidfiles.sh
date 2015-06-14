#!/bin/sh

lsof | grep " /" | awk '{pl[$2]++} END {for (a in pl) {printf("%d: %d\n", a, pl[a])}}'

exit 0
