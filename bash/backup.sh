#v0.1
# Backup the server over remote server
#!/bin/bash

# Define source, destination server, and remote path
SOURCE="/"
REMOTE_USER="test"              # Replace with your username on the remote server
REMOTE_HOST="1.2.3.4"             # The IP address of the remote server
REMOTE_DIR="<backup folder remote"             # Remote directory where backups will be stored ( /home/backup/)

# Date format for backup folder naming
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FOLDER="<backup_folder_name>"

# Exclude directories that don't need to be backed up
EXCLUDE="--exclude=/proc --exclude=/sys --exclude=/dev --exclude=/tmp --exclude=/run --exclude=/mnt --exclude=/media --exclude=/swapfile --exclude=$REMOTE_DIR"

# Create the backup folder locally before syncing (optional)
#mkdir -p "$BACKUP_FOLDER"

# Perform backup using rsync over SSH
echo "Starting backup to remote server..."

rsync -aAXv $EXCLUDE -e ssh $SOURCE "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/$BACKUP_FOLDER"

# Verify if the backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully!"
else
    echo "Backup failed!"
    exit 1
fi

