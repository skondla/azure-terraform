#!/bin/bash
#Purpose: Create netApp account, Set up netApp Capacity Pools, and Volumes

#az login

SUBSCRIPTION="7157c5e7-0f06-458b-8229-0a0f52209ee2"
RESOURCE_GROUP=chkmarx-conf-compute-mvp
LOCATION="westus"
ANF_ACCOUNT_NAME="azrnetapp"
POOL_NAME="cc-cxmarx-pool1"
POOL_SIZE_TiB=4 # Size in Azure CLI needs to be in TiB unit (minimum 4 TiB)
SERVICE_LEVEL="Standard" # Valid values are Standard, Premium and Ultra
VNET_NAME=chkmrx-mvp-vnet1
SUBNET_NAME="ANFSubnet"
VOLUME_SIZE_GiB=100 # 100 GiB
UNIQUE_FILE_PATH="azrnetappfilepath"

function setSubScription() {
    az account set --subscription ${1}
}


function registerNetApp() { 
    az provider register --namespace Microsoft.NetApp --wait
}

function createNetAppFiles() {
    az netappfiles account create \
     --resource-group ${1} \
     --location ${2} \
     --account-name ${3}
}

function createNetAppPools() {
    az netappfiles pool create \
     --resource-group ${1} \
     --location ${2} \
     --account-name ${3} \
     --pool-name ${4} \
     --size ${5} \
     --service-level ${6}
}

function createSubNet() {
    az network vnet subnet create \
     --resource-group ${1} \
     --vnet-name ${2} \
     --name ${3} \
     --address-prefixes "172.21.39.72/29" \
     --delegations "Microsoft.NetApp/volumes"
}

function createNetAppVolume() {
    az netappfiles volume create \
     --resource-group ${1} \
     --location ${2} \
     --account-name ${3} \
     --pool-name ${4} \
     --name "netappvol1" \
     --service-level ${5} \
     --vnet ${6} \
     --subnet ${7} \
     --usage-threshold ${8} \
     --file-path ${9} \
     --allowed-clients "172.21.39.128/25" \
     --protocol-types "NFSv4.1" \
     --rule-index 1
}    
     
# --encryption-key-source https://des-sast-keyvault-cc6.vault.azure.net/keys/des-keyvault-key6/d657f689d50a40b9b6bc6d8aeb10303d
# --encryption-key-source /subscriptions/7157c5e7-0f06-458b-8229-0a0f52209ee2/resourceGroups/chkmarx-conf-compute-mvp/providers/Microsoft.Compute/diskEncryptionSets/des-encrypt-set
# --kerberos-enabled true \
# --kerberos5-rw
# --export-policy '[{"allowed_clients":"172.21.39.128/25", "rule_index": "1", "unix_read_only": "false", "unix_read_write": "true", "cifs": "true", "nfsv3": "true", "nfsv3": "true", "nfsv4": "true"}]' \
# --creation-token "fQBhZrF2w6W0PhJQLohuw31ivdBU2+YkMM2A9HpaNGC80pslNJl86ElzaTsUMa41"

function main() {
    echo "Setting subscription to ${SUBSCRIPTION}"
    setSubScription ${SUBSCRIPTION}

    if [ $? -eq 0 ]; then
        echo "Registering Microsoft.NetApp provider namespace.."
        registerNetApp
    else
        echo "Unable to set subscription to ${SUBSCRIPTION}, exiting.."
        exit 0
    fi

    if [ $? -eq 0 ]; then
        echo "Creating NetApp files.."
        createNetAppFiles ${RESOURCE_GROUP} ${LOCATION} ${ANF_ACCOUNT_NAME}
    else
        echo "Unable to register Microsoft.NetApp namespace, exiting.."
        exit 0
    fi

    if [ $? -eq 0 ]; then
        echo "Creating NetApp pools.."
        createNetAppPools ${RESOURCE_GROUP} ${LOCATION} ${ANF_ACCOUNT_NAME} ${POOL_NAME} ${POOL_SIZE_TiB} ${SERVICE_LEVEL}
    else
        echo "Unable to create NetApp Files, exiting.."
        exit 0
    fi

    if [ $? -eq 0 ]; then
        echo "Creating Subnet ${SUBNET_NAME} .."
        createSubNet ${RESOURCE_GROUP} ${VNET_NAME} ${SUBNET_NAME} 
    else
        echo "Unable to create NetApp pools, exiting.."
        exit 0
    fi

    VNET_ID=$(az network vnet show --resource-group ${RESOURCE_GROUP} --name ${VNET_NAME} --query "id" -o tsv)
    SUBNET_ID=$(az network vnet subnet show --resource-group ${RESOURCE_GROUP} --vnet-name ${VNET_NAME} --name ${SUBNET_NAME} --query "id" -o tsv)

    if [ $? -eq 0 ]; then
        echo "Creating NetApp Volume.."
        createNetAppVolume ${RESOURCE_GROUP} ${LOCATION} ${ANF_ACCOUNT_NAME} ${POOL_NAME} ${SERVICE_LEVEL} ${VNET_ID} ${SUBNET_ID} $VOLUME_SIZE_GiB ${UNIQUE_FILE_PATH}
    else
        echo "Unable to create subnet, exiting.."
        exit 0
    fi


}

main


