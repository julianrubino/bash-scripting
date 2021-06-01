#!/bin/bash

### Vars

RetentionPeriod="3 months"
profile="aws-profile"

### Enable pyenv to use python 3.x to use latest awscli

export PATH="/home/jenkins/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

pyenv global 3.6.10


### Create and use virtualenv environment


virtualenv venv-python-3.6.10
. venv-python-3.6.10/bin/activate

python --version


### Install latest awscli

pip install awscli --upgrade


### Delete DynamoDB backups

OldBackupsList=$(aws dynamodb list-backups --profile ${profile} --time-range-upper-bound $(date +%s --date="${RetentionPeriod} ago") --backup-type USER | jq -r ".[]|.[].BackupArn")

if [ ${#OldBackupsList} -eq 0 ]; then
	echo -e "\n####################\nThere are no backups to delete at this time.\n####################\n"
	exit 0
fi

for i in $OldBackupsList; do
	echo -e "Deleting ${i} \n"
	aws dynamodb delete-backup --backup-arn ${i}
done