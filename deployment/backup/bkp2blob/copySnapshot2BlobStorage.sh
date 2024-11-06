#!/bin/bash
set -x
#Provide the subscription Id where snapshot is created
subscriptionId="7157c5e7-0f06-458b-8229-0a0f52209ee2"

#Provide the name of your resource group where snapshot is created
resourceGroupName="chkmarx-conf-compute-mvp"

#Provide the snapshot name 
snapshotName="osDisk-backup"

#Provide Shared Access Signature (SAS) expiry duration in seconds e.g. 3600.
#Know more about SAS here: https://docs.microsoft.com/en-us/azure/storage/storage-dotnet-shared-access-signature-part-1
sasExpiryDuration=3600

#Provide storage account name where you want to copy the snapshot. 
storageAccountName="ccstorencrypt1"

#Name of the storage container where the downloaded snapshot will be stored
storageContainerName="diskbackups"

#Provide the key of the storage account where you want to copy snapshot. 
storageAccountKey=`cat ~/.secrets/sensitive.txt | grep "storageAccountKey" | awk '{print $2}'`
#Provide the name of the VHD file to which snapshot will be copied.
destinationVHDFileName="diskBackupVHDFile"

az account set --subscription $subscriptionId

sas=$(az snapshot grant-access --resource-group $resourceGroupName --name $snapshotName --duration-in-seconds $sasExpiryDuration --query [accessSas] -o tsv)

az storage blob copy start --destination-blob $destinationVHDFileName --destination-container $storageContainerName --account-name $storageAccountName --account-key $storageAccountKey --source-uri $sas
