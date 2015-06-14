#! /bin/bash

# Backup etc and other files
logger -i -t Backup-Config -- Starting config backup via confbak
/rcutils/scripts/confbak.sh /rcutils/backups/confbak && logger -i -t Backup-Config -- confbak backup successful

# Backup etc .webmin-backup
# /rcutils/scripts/confbak-webminbackup.sh /rcutils/backups/confbak-webminbackup

# Backup trackstudio attachments
logger -i -t Backup-TSAttachments -- Starting backup of TrackStudio Attachments
/rcutils/scripts/confbak-tsattachments.sh /rcutils/backups/confbak-tsattachments && logger -i -t Backup-TSAttachments -- Backup of TS attachments successful

# kill old mail for root
logger -i -t FindPrune-RootMail -- Starting find based prune of roots mail
find /root/Maildir -type f -mtime +1 -print0 | xargs -r0 rm -f && logger -i -t FindPrune-RootMail -- Find based mail prune successful

# Just use type d to grab and kill the dirs, taking files with them
# Del old confbak directories, changing mtime figure as needed
logger -i -t FindPrune-ConfbakConfigBackup -- Starting find based prune of config backup
find /rcutils/backups/confbak -type d -mtime +1 -print0 | xargs -r0 rm -rf && logger -i -t FindPrune-ConfbakConfigBackup -- Find based config backup prune successful

# find /rcutils/backups/confbak-webminbackup -type d -mtime +6 -print0 | xargs -r0 rm -rf 

logger -i -t FindPrune-TSAttachmentBackup -- Starting find based prune of TrackStudio Attachments backup
find /rcutils/backups/confbak-tsattachments -type d -mtime +1 -print0 | xargs -r0 rm -rf && logger -i -t FindPrune-TSAttachmentBackup -- Find based prune of TrackStudio attachment backups successful

logger -i -t FindPrune-TSAttachmentBackup -- Starting find based prune of HOURLY TrackStudio Attachments backup
find /rcutils/backups/backup-webmin-ts-hourly -type d -mtime +1 -print0 | xargs -r0 rm -rf && logger -i -t FindPrune-TSAttachmentBackup -- Find based prune of HOURLY TrackStudio attachment backups successful

# Del old TS logs, changind mtime as needed
logger -i -t FindPrune-TSLogs -- Starting find based prune of TrackStudio logs
find /opt/TS/log/20*.log -type f -mtime +1 -print0 | xargs -r0 rm -f && logger -i -t FindPrune-TSLogs -- Find based prune of TrackStudio logs successful

exit 0
