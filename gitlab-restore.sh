#!/bin/bash
## Set Variables first
# Set Gitlab Container Name:
GITLABCONT=
# Set S3 bucket name:
S3BUCKET=
# Set Gitlab Working Directory:
WORKDIR=
## Set the files that you want to restore from S3
# Set the config file name
# Eg: config-202109051222.tgz
CONFFILE=
# Set timestamp of the main backup file
# Eg: 11493107454_2018_04_25_10.6.4-ce
TIMESTAMP=

# Check if variables are set
if [ -z "${CONFFILE}" ] || [ -z "${GITLABCONT}" ] || [ -z "${TIMESTAMP}" ]; then
    echo "Edit this script and Set all Variables first"
    exit
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

# Stop the processes that are connected to the database
docker exec -it ${GITLABCONT} gitlab-ctl stop puma
docker exec -it ${GITLABCONT} gitlab-ctl stop sidekiq

# Verify that the processes are all down before continuing
docker exec -it ${GITLABCONT} gitlab-ctl status

read -p "Start Restore? [y/n]: " START
START=${START:-n}

# Restore the Config folder
aws s3 sync s3://${S3BUCKET}/configbk/ ./configbk/
tar xvzf ./configbk/${CONFFILE} -C "$WORKDIR"

# Run the restore
aws s3 sync s3://${S3BUCKET}/backups ./data/backups/
docker exec -it ${GITLABCONT} gitlab-backup restore BACKUP=${TIMESTAMP}

# Restart the GitLab container
docker restart ${GITLABCONT}

# Check GitLab
echo "Check Gitlab after the container becomes healthy."
echo "Containers will be listed every 10 seconds. Press Ctrl+C after the container shows healthy status."
read -p "Check Gitlab? [y/n]: " CHECK
if [ "$CHECK" == "y" ]; then
    watch -n 10 docker ps
    docker exec -it ${GITLABCONT} gitlab-rake gitlab:check SANITIZE=true
fi
echo "Restore script completed."