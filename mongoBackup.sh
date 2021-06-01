#!/bin/bash -e

mongo_host=""
YYYYMM=$(date +"%Y%m")
TODAY=$(date +"%Y%m%d")
rm -rf *

if [[ $mongo_host == *int* ]]
then 
mongo_pass=$int_mongo_pass
mongo_user="admin"
mongo_port=27017
fi

echo mongodump --host $mongo_host --port $mongo_port --username $mongo_user --password $mongo_pass --out $TODAY

mongodump --host $mongo_host --port $mongo_port --username $mongo_user --password $mongo_pass -d models --excludeCollection=admin.system.version  --authenticationDatabase admin -numThreads 1 --out $TODAY

tar -zcvf $TODAY.tar.gz $TODAY

gpg -e -r 'jenkins_slave05' $TODAY.tar.gz

s3cmd -v --no-guess-mime-type sync $TODAY.tar.gz.gpg s3://elementum-mongobackup/$mongo_host/$YYYYMM/$TODAY.tar.gz.gpg

rm -rf *

df -h