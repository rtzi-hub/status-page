#!/bin/bash

# Define paths
BACKUP_DIR="/var/lib/jenkins/plugins/thinBackup"  # ThinBackup directory where backups are stored
GIT_REPO_DIR="/var/lib/jenkins/status-page/final-project-terraform/Jenkins/backups"  # Git repo backups folder

# Step 1: Navigate to ThinBackup folder
cd $BACKUP_DIR || exit

# Step 2: Find the latest FULL backup folder
LATEST_BACKUP=$(ls -td FULL-* | head -1)  # Finds the most recent backup starting with 'FULL'

# Step 3: Check if the backup folder exists
if [ -d "$LATEST_BACKUP" ]; then
    # Step 4: Copy the entire folder to the Git repository
    cp -r "$LATEST_BACKUP" "$GIT_REPO_DIR"
else
    echo "No FULL backup folder found!"
    exit 1
fi

# Step 5: Navigate to the Git repository folder
cd /var/lib/jenkins/status-page || exit

# Step 6: Add and commit the new backup folder to the Git repository
git add final-project-terraform/Jenkins/backups/"$LATEST_BACKUP"
git commit -m "Added Jenkins backup: $LATEST_BACKUP"
git push origin main