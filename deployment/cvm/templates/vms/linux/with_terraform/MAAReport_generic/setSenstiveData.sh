#!/bin/bash

export TF_VAR_appadminUsername=`cat /Users/skondla/.secrets/sensitive.txt|grep appadminUsername|awk '{print $2}'`
export TF_VAR_appadminPassword=`cat /Users/skondla/.secrets/sensitive.txt|grep appadminPassword|awk '{print $2}'`
export TF_VAR_dbadminUsername=`cat /Users/skondla/.secrets/sensitive.txt|grep dbadminUsername|awk '{print $2}'`
export TF_VAR_dbadminPassword=`cat /Users/skondla/.secrets/sensitive.txt|grep dbadminPassword|awk '{print $2}'`
export TF_VAR_sslExportPasswd=`cat /Users/skondla/.secrets/sensitive.txt|grep sslExportPasswd|awk '{print $2}'`
export TF_VAR_adminPublicKey=`cat ~/.ssh/chkmarx_sast_key_4096.pub`
export TF_VAR_backendPoolId="/subscriptions/7157c5e7-0f06-458b-8229-0a0f52209ee2/resourceGroups/chkmarx-conf-compute-mvp/providers/Microsoft.Network/loadBalancers/chkmarx-lb/backendAddressPools/chkmarx-lbbepool"
export TF_VAR_confidentialDiskEncryptionSetId="CheckMarx-HSM-Disk-Encryption-Set-Prod"
export TF_VAR_resource_group_name="chkmarx-conf-compute-mvp"
export TF_VAR_resource_group_name_des="sst-cxsast-mvp-cc"
export TF_VAR_storage_account="chkmarxsa"
export TF_VAR_virtual_network_name="chkmrx-mvp-vnet1"
export TF_VAR_vnet_resource_group="chkmarx-conf-compute-mvp"
#cp templatecvm.json templatecvm.json.bkup && jq '.variables.linuxConfiguration.ssh.publicKeys.keyData=env.TF_VAR_adminPublicKey' templatecvm.json > tmp.json && mv tmp.json templatecvm.json
