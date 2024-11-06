#!/bin/bash

export TF_VAR_appadminUsername=`cat /Users/skondla/.secrets/sensitive.txt|grep appadminUsername|awk '{print $2}'`
export TF_VAR_appadminPassword=`cat /Users/skondla/.secrets/sensitive.txt|grep appadminPassword|awk '{print $2}'`
export TF_VAR_dbadminUsername=`cat /Users/skondla/.secrets/sensitive.txt|grep dbadminUsername|awk '{print $2}'`
export TF_VAR_dbadminPassword=`cat /Users/skondla/.secrets/sensitive.txt|grep dbadminPassword|awk '{print $2}'`
export TF_VAR_sslExportPasswd=`cat /Users/skondla/.secrets/sensitive.txt|grep sslExportPasswd|awk '{print $2}'`
export TF_VAR_pubKey=`cat ~/.ssh/chkmarx_sast_key_4096.pub`
export TF_VAR_nfsv3_enabled="true"
export TF_VAR_enable_https_traffic_only="true"
export TF_VAR_min_tls_version="TLS1_2"
export TF_VAR_large_file_share_enabled="true"
export TF_VAR_infrastructure_encryption_enabled="true"
export TF_VAR_is_hns_enabled="true"
export TF_VAR_confidentialDiskEncryptionSetId="CheckMarx-HSM-Disk-Encryption-Set-Prod"
export TF_VAR_vnet_cidr_block="172.21.39.0/24"
export TF_VAR_myshare_nfs="cc-azr-nfs-encypt-files"
export TF_VAR_myshare_smb="cc-azr-smb-encrypt-files"
