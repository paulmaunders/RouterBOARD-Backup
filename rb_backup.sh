#!/bin/bash

Copyright (c) <year> <copyright holders>

# Permission is hereby granted, free of charge, to any person obtaining a 
# copy of this software and associated documentation files (the "Software"), 
# to deal in the Software without restriction, including without limitation 
# the rights to use, copy, modify, merge, publish, distribute, sublicense, 
# and/or sell copies of the Software, and to permit persons to whom the 
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included 
# in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
# IN THE SOFTWARE.

# ==== Settings ====

# Specify the folder where backups will be stored
BACKUP_FOLDER=/mnt/backups/routers

# Specify the hostnames of your RouterBOARDs here...
ROUTERS=(
 "rb1.test.tld"
)

# ==== Script ====

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
