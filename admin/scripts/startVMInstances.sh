#!/bin/bash
#Purpose: Use this script to start VM. 

resourceGroup="dc-rg-sast"
subscription="45adad4f-3a50xxxxx-yyyyyy-zzzz"
#az vm list -g dc-rg-sast --query "[].id" -o tsv| cut -d '/' -f 9
#az vm stop --resource-group dc-rg-sast --name Bastion --subscription 45adad4f-3a50xxxxx-yyyyyy-zzzz

#Stop VM instances from resource group

for vm in `az vm list -g ${resourceGroup} --query "[].id" -o tsv| cut -d '/' -f 9`
do
    echo "Starting virtual machine ${vm}..."
    az vm start --resource-group ${resourceGroup} --name ${vm} --subscription ${subscription}
done


