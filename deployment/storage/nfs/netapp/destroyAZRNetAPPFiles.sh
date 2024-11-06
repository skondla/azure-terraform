#!/bin/bash
#Purpose: Create netApp account, Set up netApp Capacity Pools, and Volumes

#az login

SUBSCRIPTION="7157c5e7-0f06-458b-8229-0a0f52209ee2"
RESOURCE_GROUP=chkmarx-conf-compute-mvp
LOCATION="westus"
ANF_ACCOUNT_NAME="azrnetapp"
POOL_NAME="mypool1"
POOL_SIZE_TiB=4 # Size in Azure CLI needs to be in TiB unit (minimum 4 TiB)
SERVICE_LEVEL="Premium" # Valid values are Standard, Premium and Ultra
VNET_NAME=chkmrx-mvp-vnet1
SUBNET_NAME="ANFSubnet"
VOLUME_SIZE_GiB=100 # 100 GiB
UNIQUE_FILE_PATH="azrnetappfilepath"

function setSubScription() {
    az account set --subscription ${1}
}


function unregisterNetApp() { 
    az provider unregister --namespace Microsoft.NetApp --wait
}

function deleteNetAppFiles() {
    az netappfiles account delete \
     --resource-group ${1} \
     --account-name ${2}
}

function deleteNetAppPools() {
    az netappfiles pool delete \
     --resource-group ${1} \
     --account-name ${2} \
     --pool-name ${3} 

}

function deleteSubNet() {
    az network vnet subnet delete \
     --resource-group ${1} \
     --vnet-name ${2} \
     --name ${3} 
}

VNET_ID=$(az network vnet show --resource-group ${RESOURCE_GROUP} --name ${VNET_NAME} --query "id" -o tsv)
SUBNET_ID=$(az network vnet subnet show --resource-group ${RESOURCE_GROUP} --vnet-name ${VNET_NAME} --name ${SUBNET_NAME} --query "id" -o tsv)

function deleteNetAppVolume() {
    az netappfiles volume delete \
     --resource-group ${1} \
     --account-name ${2} \
     --pool-name ${3} \
     --volume-name "netappvol1" 
}

function main() {
    echo "Setting subscription to ${SUBSCRIPTION}"
    setSubScription ${SUBSCRIPTION}

    if [ $? -eq 0 ]; then
        echo "Deleting NetApp Volume.."
        deleteNetAppVolume ${RESOURCE_GROUP} ${ANF_ACCOUNT_NAME} ${POOL_NAME}
    else
        echo "Unable to set subscription to ${SUBSCRIPTION}, exiting.."
        exit 0
    fi

    if [ $? -eq 0 ]; then
        echo "Deleting Subnet.."
        deleteSubNet ${RESOURCE_GROUP} ${VNET_NAME} ${SUBNET_NAME} 
    else
        echo "Unable to delete NetApp Volume., exiting.."
        exit 0
    fi

    if [ $? -eq 0 ]; then
        echo "Deletomg NetApp pools.."
        deleteNetAppPools ${RESOURCE_GROUP} ${ANF_ACCOUNT_NAME} ${POOL_NAME}
    else
        echo "Unable to delete subnet ${SUBNET_NAME} , exiting.."
        exit 0
    fi

    if [ $? -eq 0 ]; then
        echo "Deleting NetApp files .."
        deleteNetAppFiles ${RESOURCE_GROUP} ${ANF_ACCOUNT_NAME}
    else
        echo "Unable to NetApp pools, exiting.."
        exit 0
    fi
    if [ $? -eq 0 ]; then
        echo "Unregistering namespace Microsoft.NetApp .."
        unregisterNetApp
    else
        echo "Unable to NetApp files, exiting.."
        exit 0
    fi

    if [ $? -eq 0 ]; then
        echo "Unregistering namespace Microsoft.NetApp is successful.."
    else
        echo "Unregistering namespace Microsoft.NetApp is failed.."
        exit 0
    fi
    

}

main


