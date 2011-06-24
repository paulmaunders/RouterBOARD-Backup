# RouterBOARD Backup

## Overview

A bash script to help archive Mikrotik RouterBoard backups to another server via scp. 

## Instructions

### Step 1 - Generate a DSA key on your backup server and copy to your RouterBOARD(s) ###

If your backup server doesn't already have a DSA keypair, you will need to generate one. To do this, log in to your backup server and run:
    
    ssh-keygen -t dsa

Next, upload your backup server's public key to each RouterBOARD that you wish to backup. NB: You must use a DSA key, 
    
    scp id_dsa.pub admin@rb1.test.tld:

### Step 2 - Configure scheduled backups on each RouterBOARD ###

Now go to each router and run the following commands... (ensuring you change 1.1.1.1 to your backup server's IP)

    #Add a group for backups with only SSH and read permissions
    user group add name="backup" policy="read,ssh,sensitive"
    #Create a read only user to download the backups
    user add name=backup group=backup address=1.1.1.1
    #Import the key 
    user ssh-keys import public-key-file=id_dsa.pub user=backup
    #Setup a backup task and add to the scheduler (note it won't start until the next day, so we run it once manually)
    system script add name="backup-script" source="/system backup save name=backup"
    system scheduler add name="Backup Task" on-event="backup-script" start-time="06:00:00" interval=1d
    system script run backup-script
    
### Step 3 - Install rb_backup.sh on your backup server ###
  
Edit the rb_backup.sh script to include the hostnames of all the routers you wish to backup, and edit the BACKUP_FOLDER to point at the directory where you want the backups to be stored. 

Try running rb_backup.sh. If you have any problems, try manually ssh'ing to each RouterBOARD to ensure it works first.

    ssh backup@rb1.test.tld

You may wish to install the rb_backup.sh script on the cron.
