#!/bin/bash
# ==============================
# =         VARIABLES          =
# ==============================
#### ===== Backup Flags =====
# "never" - Do not back up
# "hourly" - Back up on every run
# "daily" - Back up daily, on the hour specified for Catalog Updates
# "weekly" - Back up weekly, on the day and hour specified for Catalog Updates
# "monthly" - Back up monthly, on the day and hour specified for Catalog Updates
BACKUP_SYSTEM_SETTINGS="hourly"
BACKUP_FILES="never"
BACKUP_LDAP="hourly"
BACKUP_FILEMAKER="never"
BACKUP_MYSQL="hourly"
#### ===== End Backup Flags =====
#
#### ===== Backup Paths =====
# Specify directories (not files) to backup here, no trailing slash
# ie:
# BACKUP_PATHS[0]="/etc"
# BACKUP_PATHS[1]="/tmp"
# BACKUP_PATHS[2]="/somewhere/else"
BACKUP_PATHS[0]="/etc"
BACKUP_PATHS[0]="/Library/Preferences"
#### ===== End Backup Paths =====
#
#### ===== Login & Configuration Info =====
# Enter your login details here
FILEMAKER_USERNAME=
FILEMAKER_PASSWORD=
FILEMAKER_BACKUP_SCHEDULE="1"
# Schedule Type = "Hourly", "Daily" or "Weekly"
FILEMAKER_SCHEDULE_TYPE="Hourly"
FILEMAKER_BACKUP_PATH="/Library/FileMaker Server/Data/Backups/"
MYSQL_USERNAME=root
MYSQL_PASSWORD=eSolia1!
#### ===== End Login & Configuration Info =====
#
#### ===== Paths and Files =====
# Get the current path. This is reliable on os x or other *nix bash.
ABSPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
CURRENT=`dirname "$ABSPATH"`
FULLBACKUP_FILENAME=`hostname`-fullbackup-`date +%Y%m%d%-%H%M`
# Backup Mirrors
# -Enclose paths with spaces in quotes, no trailing slash
# ie:
#BACKUP_MIRRORS[0]="/Volumes/Backup1/Backups"
#BACKUP_MIRRORS[1]="/Volumes/Backup2/Backups"
#BACKUP_MIRRORS[2]="/Volumes/Backup3/Backups"
BACKUP_MIRRORS[0]="/Volumes/eSolia LaCie 1TB 02/Backups"
# Cron's env is different from the normal shell's, so specify cmd paths for anything non builtin.
CMDSLAPCONFIG=/usr/sbin/slapconfig
CMDSERVERADMIN=/usr/sbin/serveradmin
CMDMYSQLDUMP=/usr/bin/mysqldump
CMDFMSADMIN=/usr/bin/fmsadmin
CMDRSYNC=/usr/local/maclemon/bin/rsync
#### ===== End Paths and Files =====
#
#### ===== Catalog Updates =====
## *_BACKUPS_HOUR is a two-digit number 00-23
## WEEKLY_BACKUPS_DAY is a one-digit number 1-7, with 1 being Monday
## MONTHLY_BACKUPS_DAY is a two-digit number 01-28
DAILY_BACKUPS_HOUR="12"
WEEKLY_BACKUPS_DAY="2"
WEEKLY_BACKUPS_HOUR="09"
MONTHLY_BACKUPS_DAY="24"
MONTHLY_BACKUPS_HOUR="09"
#### ===== End Catalog Updates =====
#
#### ===== Catalog Counts =====
## Indicate the number of backups to keep for each catalog.
HOURLY_BACKUPS=24
DAILY_BACKUPS=7
WEEKLY_BACKUPS=4
MONTHLY_BACKUPS=12
#### ===== End Catalog Counts =====
#
# Check environment for Debug
# env
#
# ==============================
# =            PREP            =
# ==============================
# Get the current time info
CURRENT_HOUR=`date +%H`
CURRENT_DOW=`date +%u`
CURRENT_DOM=`date +%d`
# -Decide Catalog Updates
echo "Deciding catalog updates .."
DO_HOURLY_BACKUP=1
DO_DAILY_BACKUP=0
if [ "$CURRENT_HOUR" = "$DAILY_BACKUPS_HOUR" ]; then DO_DAILY_BACKUP=1; fi
DO_WEEKLY_BACKUP=0
if [ "$CURRENT_DOW" = "$WEEKLY_BACKUPS_DAY" -a "$CURRENT_HOUR" = "$WEEKLY_BACKUPS_HOUR" ]; then DO_WEEKLY_BACKUP=1; fi
DO_MONTHLY_BACKUP=0
if [ "$CURRENT_DOM" = "$MONTHLY_BACKUPS_DAY" -a "$CURRENT_HOUR" = "$MONTHLY_BACKUPS_HOUR" ]; then DO_MONTHLY_BACKUP=1; fi
echo "Successfully decided catalog updates."
# -Decide what to backup
echo "Deciding what to backup .."
# --System Settings
DO_SYSTEM_SETTINGS_BACKUP=0
if [ "$BACKUP_SYSTEM_SETTINGS" = "hourly" -a "$DO_HOURLY_BACKUP" = "1" ]; then DO_SYSTEM_SETTINGS_BACKUP=1;
else if [ "$BACKUP_SYSTEM_SETTINGS" = "daily" -a "$DO_DAILY_BACKUP" = "1" ]; then DO_SYSTEM_SETTINGS_BACKUP=1;
else if [ "$BACKUP_SYSTEM_SETTINGS" = "weekly" -a "$DO_WEEKLY_BACKUP" = "1" ]; then DO_SYSTEM_SETTINGS_BACKUP=1;
else if [ "$BACKUP_SYSTEM_SETTINGS" = "monthly" -a "$DO_MONTHLY_BACKUP" = "1" ]; then DO_SYSTEM_SETTINS_BACKUP=1;
fi fi fi fi
# --Files
DO_FILES_BACKUP=0
if [ "$BACKUP_FILES" = "hourly" -a "$DO_HOURLY_BACKUP" = "1" ]; then DO_FILES_BACKUP=1;
else if [ "$BACKUP_FILES" = "daily" -a "$DO_DAILY_BACKUP" = "1" ]; then DO_FILES_BACKUP=1;
else if [ "$BACKUP_FILES" = "weekly" -a "$DO_WEEKLY_BACKUP" = "1" ]; then DO_FILES_BACKUP=1;
else if [ "$BACKUP_FILES" = "monthly" -a "$DO_MONTHLY_BACKUP" = "1" ]; then DO_FILES_BACKUP=1;
fi fi fi fi
# --LDAP
DO_LDAP_BACKUP=0
if [ "$BACKUP_LDAP" = "hourly" -a "$DO_HOURLY_BACKUP" = "1" ]; then DO_LDAP_BACKUP=1;
else if [ "$BACKUP_LDAP" = "daily" -a "$DO_DAILY_BACKUP" = "1" ]; then DO_LDAP_BACKUP=1;
else if [ "$BACKUP_LDAP" = "weekly" -a "$DO_WEEKLY_BACKUP" = "1" ]; then DO_LDAP_BACKUP=1;
else if [ "$BACKUP_LDAP" = "monthly" -a "$DO_MONTHLY_BACKUP" = "1" ]; then DO_LDAP_BACKUP=1;
fi fi fi fi
# --FileMaker
DO_FILEMAKER_BACKUP=0
if [ "$BACKUP_FILEMAKER" = "hourly" -a "$DO_HOURLY_BACKUP" = "1" ]; then DO_FILEMAKER_BACKUP=1;
else if [ "$BACKUP_FILEMAKER" = "daily" -a "$DO_DAILY_BACKUP" = "1" ]; then DO_FILEMAKER_BACKUP=1;
else if [ "$BACKUP_FILEMAKER" = "weekly" -a "$DO_WEEKLY_BACKUP" = "1" ]; then DO_FILEMAKER_BACKUP=1;
else if [ "$BACKUP_FILEMAKER" = "monthly" -a "$DO_MONTHLY_BACKUP" = "1" ]; then DO_FILEMAKER_BACKUP=1;
fi fi fi fi
# --MySQL
DO_MYSQL_BACKUP=0
if [ "$BACKUP_MYSQL" = "hourly" -a "$DO_HOURLY_BACKUP" = "1" ]; then DO_MYSQL_BACKUP=1;
else if [ "$BACKUP_MYSQL" = "daily" -a "$DO_DAILY_BACKUP" = "1" ]; then DO_MYSQL_BACKUP=1;
else if [ "$BACKUP_MYSQL" = "weekly" -a "$DO_WEEKLY_BACKUP" = "1" ]; then DO_MYSQL_BACKUP=1;
else if [ "$BACKUP_MYSQL" = "monthly" -a "$DO_MONTHLY_BACKUP" = "1" ]; then DO_MYSQL_BACKUP=1;
fi fi fi fi
# --Note
if [ "$DO_SYSTEM_SETTINGS_BACKUP" = "1" ]; then echo "Will backup system settings"; fi
if [ "$DO_FILES_BACKUP" = "1" ]; then echo "Will backup files"; fi
if [ "$DO_LDAP_BACKUP" = "1" ]; then echo "Will backup LDAP"; fi
if [ "$DO_FILEMAKER_BACKUP" = "1" ]; then echo "Will backup FileMaker"; fi
if [ "$DO_MYSQL_BACKUP" = "1" ]; then echo "Will backup MySQL"; fi
echo "Successfully decided what to backup."
# -Prepare Working Directory
echo "Preparing working directory .."
for dir in $(ls -d $CURRENT/working/*/); do rm -Rv $dir; mkdir $dir; done
for fn in $(find $CURRENT/working -type f); do rm -v $fn; done
echo "Successfully prepared working directory."
#
# ==============================
# =          BACKUP            =
# ==============================
echo "Beginning backup .."
# -System Settings
if [ "$DO_SYSTEM_SETTINGS_BACKUP" = "1" ]; then
echo "Backing up system settings .."
for f in $($CMDSERVERADMIN list); do
        echo "Backing up $f settings"
        $CMDSERVERADMIN settings $f > $CURRENT/working/sys/$f-settings.backup
done
echo "Successfully backed up system settings."
fi
# -Files
if [ "$DO_FILES_BACKUP" = "1" ]; then
echo "Backing up files .."
PATHS_COUNT=${#BACKUP_PATHS[@]}
INDEX=0;
while [ "$INDEX" -lt "$PATHS_COUNT" ]; do
echo "Backing up path ${BACKUP_PATHS[$INDEX]}"
# --Quote paths for safety
mkdir -pv "$CURRENT/working/files/${BACKUP_PATHS[$INDEX]}"
cp -R -v "${BACKUP_PATHS[$INDEX]}/" "$CURRENT/working/files/${BACKUP_PATHS[$INDEX]}"
((INDEX++))
done
echo "Successfully backed up files."
fi
# -LDAP
if [ "$DO_LDAP_BACKUP" = "1" ]; then
echo "Backing up OpenDirectory .."
$CMDSLAPCONFIG -backupdb -noEncrypt $CURRENT/working/ldap/opendirectory-backup
echo "Successfully backed up OpenDirectory."
fi
# -FileMaker
if [ "$DO_FILEMAKER_BACKUP" = "1" ]; then
echo "Backing up FileMaker .."
$CMDFMSADMIN RUN schedule $FILEMAKER_BACKUP_SCHEDULE -u $FILEMAKER_USERNAME -p $FILEMAKER_PASSWORD
LATEST_FILEMAKER_BACKUP=$(ls -1t "$FILEMAKER_BACKUP_PATH" | grep "$FILEMAKER_SCHEDULE_TYPE" | head -1)
echo "Pulling FileMaker backup at $LATEST_FILEMAKER_BACKUP"
tar -cvvf $CURRENT/working/fm/fm-backup.tar "$FILEMAKER_BACKUP_PATH/$LATEST_FILEMAKER_BACKUP"
echo "Successfully backed up FileMaker."
fi
# -MySQL
if [ "$DO_MYSQL_BACKUP" = "1" ]; then
echo "Backing up MySQL .."
$CMDMYSQLDUMP --skip-opt --all-databases --add-locks --comments --complete-insert --create-options --dump-date --extended-insert --lock-tables --set-charset --quick --routines --triggers --verbose --result-file="$CURRENT/working/mysql/fulldump.sql" --host localhost --user=$MYSQL_USER --password=$MYSQL_PASSWORD
echo "Successfully backed up MySQL."
fi
echo "Successfully backed up everything."
# -Archive
echo "Creating full backup archive $FULLBACKUP_FILENAME.tar .."
rm $CURRENT/latest/*
tar -cvvf $CURRENT/latest/$FULLBACKUP_FILENAME.tar $CURRENT/working
echo "Successfully created full backup archive."
# -Compressed Archive
echo "Compressing full backup archive .."
gzip $CURRENT/latest/$FULLBACKUP_FILENAME.tar
gzip -l $CURRENT/latest/$FULLBACKUP_FILENAME.tar.gz
echo "Successfully compressed full backup archive."
#
# ==============================
# =          CLEANUP           =
# ==============================
echo "Cleaning up working directory .."
for dir in $(ls -d $CURRENT/working/*/); do rm -Rv $dir; mkdir $dir; done
for fn in $(find $CURRENT/working -type f); do rm -v $fn; done
echo "Successfully cleaned up working directory."
#
# ==============================
# =        CATALOG              =
# ==============================
echo "Updating backups catalog .."
# -Hourly Backups
if [ "$DO_HOURLY_BACKUP" = "1" ]; then
echo "Updating hourly backups catalog .."
cp $CURRENT/latest/$FULLBACKUP_FILENAME.tar.gz $CURRENT/hourly/$FULLBACKUP_FILENAME.tar.gz
COUNT=$(ls -1 $CURRENT/hourly | wc -l)
while [ "$COUNT" -gt "$HOURLY_BACKUPS" ]; do
OLDEST_FILENAME=$(ls -1t $CURRENT/hourly | tail -1)
echo "Removing old hourly $OLDEST_FILENAME"
rm $CURRENT/hourly/$OLDEST_FILENAME
COUNT=$(ls -1t $CURRENT/hourly | wc -l)
done
echo "Successfully updated hourly backups catalog."
fi
# -Daily Backups
if [ "$DO_DAILY_BACKUP" = "1" ]; then
echo "Updating daily backups catalog .."
cp $CURRENT/latest/$FULLBACKUP_FILENAME.tar.gz $CURRENT/daily/$FULLBACKUP_FILENAME.tar.gz
COUNT=$(ls -1 $CURRENT/daily | wc -l)
while [ "$COUNT" -gt "$DAILY_BACKUPS" ]; do
OLDEST_FILENAME=$(ls -1t $CURRENT/daily | tail -1)
echo "Removing old daily $OLDEST_FILENAME"
rm $CURRENT/daily/$OLDEST_FILENAME
COUNT=$(ls -1 $CURRENT/daily | wc -l)
done
echo "Successfully updated daily backups catalog."
fi
# -Weekly Backups
if [ "$DO_WEEKLY_BACKUP" = "1" ]; then
echo "Updating weekly backups catalog .."
cp $CURRENT/latest/$FULLBACKUP_FILENAME.tar.gz $CURRENT/weekly/$FULLBACKUP_FILENAME.tar.gz
COUNT=$(ls -1 $CURRENT/weekly | wc -l)
while [ "$COUNT" -gt "$WEEKLY_BACKUPS" ]; do
OLDEST_FILENAME=$(ls -1t $CURRENT/weekly | tail -1)
echo "Removing old weekly $OLDEST_FILENAME"
rm $CURRENT/weekly/$OLDEST_FILENAME
COUNT=$(ls -1 $CURRENT/weekly | wc -l)
done
echo "Successfully updated weekly backups catalog."
fi
# -Monthly Backups
if [ "$DO_MONTHLY_BACKUP" = "1" ]; then
echo "Updating monthly backups catalog .."
cp $CURRENT/latest/$FULLBACKUP_FILENAME.tar.gz $CURRENT/monthly/$FULLBACKUP_FILENAME.tar.gz
COUNT=$(ls -1 $CURRENT/monthly | wc -l)
while [ "$COUNT" -gt "$MONTHLY_BACKUPS" ]; do
OLDEST_FILENAME=$(ls -1t $CURRENT/monthly | tail -1)
echo "Removing old monthly $OLDEST_FILENAME"
rm $CURRENT/monthly/$OLDEST_FILENAME
COUNT=$(ls -1 $CURRENT/monthly | wc -l)
done
echo "Successfully update monthly backups catalog."
fi
echo "Successfully updated backups catalog."
#
# ==============================
# =         PARANOIA           =
# ==============================
echo "Syncing backup catalog to all mirrors .."
MIRRORS_COUNT=${#BACKUP_MIRRORS[@]}
INDEX=0;
while [ "$INDEX" -lt "$MIRRORS_COUNT" ]; do
echo "Syncing to mirror at ${BACKUP_MIRRORS[$INDEX]}"
# -Quote paths for safety
rsync -av "$CURRENT/" "${BACKUP_MIRRORS[$INDEX]}"
((INDEX++))
done
echo "Successfully synced backup catalog to all mirrors."
