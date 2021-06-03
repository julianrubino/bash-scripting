#!/bin/bash
es_endpoint=""
for index in $(curl -XGET "http://$es_endpoint/_all/_settings?pretty" -s | jq 'keys' | sed 's/["|,]//g' | grep -E '[[:alpha:]]+'); do
    index_documents_number=$(curl -X GET "http://$es_endpoint/$index/_count" -s | jq '.count')
    if (( $index_documents_number == 0 ));
    then
        echo "[+] Index $index is empty."
        curl -XDELETE "http://$es_endpoint/$index"
        echo "[+] Index $index deleted."
    else
        echo "[+] Index $index documents quantity -> $index_documents_number"
        echo "[+] Index $index will not be deleted"
    fi
done