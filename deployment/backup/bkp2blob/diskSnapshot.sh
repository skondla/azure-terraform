#!/bin/bash

set -x 
RESOURCE_GROUP="chkmarx-conf-compute-mvp"
osDiskId=$(az vm show \
   -g ${RESOURCE_GROUP} \
   -n cvm-linux-1 \
   --query "storageProfile.osDisk.managedDisk.id" \
   -o tsv)

az snapshot create \
    -g ${RESOURCE_GROUP} \
   --source "$osDiskId" \
   --name osDisk-backup 
