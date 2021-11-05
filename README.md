# Gitlab Backup and Restore

Shell Scripts that I use to backup and restore self managed Gitlab.

## Getting started

### Prerequisites

- AWS CLI
- S3 bucket for storing Gitlab backups

### gitlab-backup.sh

Fill in the values for the variables and add this script in the crontab of root, like so:

```
00 21 * * * /path/to/gitlab-backup.sh 1>/dev/null 2>&1
```

### gitlab-restore.sh

- Install and Configure the AWS CLI
- Create a project folder and add this script in it
- Fill in the values for the variables and run the script

### Feedbacks and Suggestions are welcome!

Just send a mail to melrockz@gmail.com