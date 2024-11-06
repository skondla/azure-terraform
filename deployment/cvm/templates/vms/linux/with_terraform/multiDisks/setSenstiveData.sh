#!/bin/bash

export TF_VAR_appadminUsername=`cat /Users/skondla/.secrets/sensitive.txt|grep appadminUsername|awk '{print $2}'`
export TF_VAR_appadminPassword=`cat /Users/skondla/.secrets/sensitive.txt|grep appadminPassword|awk '{print $2}'`
export TF_VAR_dbadminUsername=`cat /Users/skondla/.secrets/sensitive.txt|grep dbadminUsername|awk '{print $2}'`
export TF_VAR_dbadminPassword=`cat /Users/skondla/.secrets/sensitive.txt|grep dbadminPassword|awk '{print $2}'`
export TF_VAR_sslExportPasswd=`cat /Users/skondla/.secrets/sensitive.txt|grep sslExportPasswd|awk '{print $2}'`
export TF_VAR_pubKey=`cat ~/.ssh/chkmarx_sast_key_4096.pub`
cp parameters.json parameters.json.bkup && jq '.adminPublicKey.value=env.TF_VAR_pubKey' parameters.json > tmp.json && mv tmp.json parameters.json
