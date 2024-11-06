#!/bin/bash
#Purpose: Use this script to stop VM. Stopping a VM instance with stop option still incur cost

resourceGroup="dc-rg-sast"
subscription="45adad4f-3a50xxxxx-yyyyyy-zzzz"
#az vm list -g dc-rg-sast --query "[].id" -o tsv| cut -d '/' -f 9
#az vm stop --resource-group dc-rg-sast --name Bastion --subscription 45adad4f-3a50xxxxx-yyyyyy-zzzz

#Stop VM instances from resource group

for vm in `az vm list -g ${resourceGroup} --query "[].id" -o tsv| cut -d '/' -f 9`
do
    echo "Stoping virtual machine ${vm}..."
    az vm stop --resource-group ${resourceGroup} --name ${vm} --subscription ${subscription}
done


