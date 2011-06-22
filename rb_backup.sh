#!/bin/bash
BACKUP_FOLDER=/mnt/backups/routers
ROUTERS=(
 "rb1.test.tld"
)


for HOST in "${ROUTERS[@]}"
do
	BACKUPID="$(date +%s)"
	echo $HOST $BACKUPID
	HOST_BACKUP_FOLDER=$BACKUP_FOLDER/$HOST
	if [ ! -d "$HOST_BACKUP_FOLDER" ]; then 
		mkdir -p $HOST_BACKUP_FOLDER 
	fi
	scp backup@$HOST:backup.backup $HOST_BACKUP_FOLDER/$HOST-$BACKUPID.backup
	gzip $HOST_BACKUP_FOLDER/$HOST-$BACKUPID.backup
	# Delete old backups if we have plenty
	BACKUP_COUNT=`find $HOST_BACKUP_FOLDER -name *.backup.gz -type f | wc -l`
	if [ $BACKUP_COUNT -gt 5 ]; then
		echo $BACKUP_COUNT backups found. Removing any older than 14 days.
		find $HOST_BACKUP_FOLDER -name *.backup.gz -type f -mtime +14 -delete
	else 
		echo $BACKUP_COUNT backups found. Not removing any.
	fi 		

done
