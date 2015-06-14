#!/bin/sh
echo ==
echo Number of open files via lsof
lsof|wc -l
echo ==
echo Breakdown:
lsof | awk '{ print $3 }' | sort | uniq -c | sort -nr

echo ==
echo Per Process limits via ulimit -a
ulimit -a
echo ==
echo Max number of file descriptors via /proc/sys/fs/file-max
cat /proc/sys/fs/file-max
echo ==
echo How many file descriptors in use, via /proc/sys/fs/file-nr
echo Allocated FDs, Free Alloc FD, Max FDs
cat /proc/sys/fs/file-nr
echo ==
echo Limits for every logons via /etc/security/limits.conf
cat /etc/security/limits.conf
echo ==
lsof
exit 0
