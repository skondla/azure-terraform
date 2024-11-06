#!/bin/bash

# This role assignment allows F5 Security Team to create new Managed HSMs
az role assignment create --assignee-object-id $(az ad group show -g 'F5 Security Team' --query 'objectId' -o tsv) --assignee-principal-type Group --role "Managed HSM Contributor"

# This role assignment allows F5 Security Team to become administrator of existing managed HSM
az keyvault role assignment create  --hsm-name ccKVHsm1 --assignee $(az ad group show -g 'F5 Security Team' --query 'objectId' -o tsv) --scope / --role "Managed HSM Administrator"

# Enable logging
hsmresource=$(az keyvault show --hsm-name ccKVHsm1 --query id -o tsv)
storageresource=$(az storage account show --name confcomptfstatebzbs8znh --query id -o tsv)
az monitor diagnostic-settings create --name MHSM-Diagnostics --resource $hsmresource --logs    '[{"category": "AuditEvent","enabled": true}]' --storage-account $storageresource

# Assign the "Crypto Auditor" role to F5 App Auditors group. It only allows them to read.
az keyvault role assignment create  --hsm-name ccKVHsm1 --assignee $(az ad group show -g 'F5 App Auditors' --query 'objectId' -o tsv) --scope / --role "Managed HSM Crypto Auditor"

# Grant the "Crypto User" role to the VM's managed identity. It allows to create and use keys. 
# However it cannot permanently delete (purge) keys
az keyvault role assignment create  --hsm-name ccKVHsm1 --assignee $(az vm identity show --name "vmname" --resource-group "confidential-compute-hsm" --query objectId -o tsv) --scope / --role "Managed HSM Crypto Auditor"

# Assign "Managed HSM Crypto Service Encryption User" role to the Storage account ID
storage_account_principal=$(az storage account show --id $storageresource --query identity.principalId -o tsv)
# (if no identity exists), then assign a new one
[ "$storage_account_principal" ] || storage_account_principal=$(az storage account update --assign-identity --id $storageresource)

az keyvault role assignment create --hsm-name ccKVHsm1 --role "Managed HSM Crypto Service Encryption User" --assignee $storage_account_principal

