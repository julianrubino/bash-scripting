#!/bin/bash

listfile=$(mktemp)
bucketname=$1
prefix=$2
jsonprepend='{"Objects":['
jsonappend='],"Quiet": false}'

function preparepayload {
        ### put 1000 records in a tempfile, then delete them from the list
        tempfile=$(mktemp)
        head -1000 ${listfile} > ${tempfile}
        sed -i '1,1000d' ${listfile}

        ### wrap all lines in brackets and put a comma, then remove comma from the last line
        sed -i -e 's/^/{/' -e 's/$/},/' ${tempfile}
        sed -i '$s/,//' ${tempfile}

        ### prepend json format
        tempfile2=$(mktemp)
        echo ${jsonprepend} > ${tempfile2}
        cat ${tempfile} >> ${tempfile2}
        mv ${tempfile2} ${tempfile}

        ### append json format
        echo ${jsonappend} >> ${tempfile}
}

function getobjectlist {
        aws s3api list-objects-v2 --bucket ${bucketname} --prefix ${prefix} | grep Key | sed 's/,//' > ${listfile}
}

### prepare an object list retaining some json formatting for convenience
getobjectlist

###While the objectlist is not empty, delete batches of items
while [ $(wc -l ${listfile} | awk '{print $1}') -gt 0 ]; do

        preparepayload
        aws s3api delete-objects --bucket ${bucketname} --delete file://${tempfile}
        rm ${tempfile}
done

### remove the listfile from /tmp
rm ${listfile}