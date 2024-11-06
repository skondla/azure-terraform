#/bin/bash

set -x

resourceGroupName="chkmarx-conf-compute-mvp"
storageAccount="chkmarxsafiles"
keyVault="des-sast-keyvault-cc6"

az storage account update \
 --name ${storageAccount} \
 --resource-group ${resourceGroupName} \
 --assign-identity


 principalId = $(az storage account show --name chkmarxsafiles --resource-group chkmarx-conf-compute-mvp --query identity.principalId)

 az keyvault set-policy \
    --name ${keyVault} \
    --resource-group ${resourceGroupName}
    --object-id $principalId \
    --key-permissions get unwrapKey wrapKey