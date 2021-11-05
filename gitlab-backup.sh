#!/bin/bash
# Set Variables first
# Set Gitlab Container Name:
GITLABCONT=
# Set S3 bucket name:
S3BUCKET=
# Set Gitlab Working Directory:
WORKDIR=

# Check if variables are set
if [ -z "$GITLABCONT" ] || [ -z "$S3BUCKET" ] || [ -z "$WORKDIR" ]; then
    echo "Edit this script and Set all Variables first"
    exit 1
fi

# check if run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# check if aws cli is installed
if [ ! -e "$(which aws)" ]; then
    apt install awscli
    echo "AWS CLI installed."
fi

# change to Gitlab working dir
cd "$WORKDIR"

# Folder Checks
if [ ! -d "./configbk" ]; then
    mkdir configbk
fi

# Gitlab Config folder backup
echo "Backing up the Config folder to S3..."
TIMESTAMP=$(date +%Y%m%d-%H%M)
tar -cvzf ./configbk/config-${TIMESTAMP}.tgz config/
aws s3 sync ./configbk/ s3://${S3BUCKET}/configbk/
if [ $? -eq 0 ]; then
    echo "Gitlab Config Sync to S3 Succeeded"
else
    echo "Gitlab Config Sync to S3 Failed"
fi
# Delete Config backups older than 30 days
find ./configbk -type f -mtime +30 -delete

# Gitlab Main backup
echo "Backing up Gitlab..."
docker exec -t ${GITLABCONT} gitlab-backup create STRATEGY=copy DIRECTORY=daily CRON=1 SKIP=registry
aws s3 sync ./data/backups/ s3://${S3BUCKET}/backups
if [ $? -eq 0 ]; then
    echo "Gitlab Backup Sync to S3 Succeeded"
else
    echo "Gitlab Backup Sync to S3 Failed"
fi
# Delete Gitlab Backups older than 30 days
find ./data/backups -type f -mtime +30 -delete