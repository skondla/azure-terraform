#!/bin/bash
#Purpose: Create custom Image from VM
set -x

#az account set --subscription "23583f43-xxxx-abcd-kstr-yyyyyyyyy"

if [ $# -lt 3 ];
then
	echo "USAGE: $0 <options {resourceGroup, vmName, imageName}>"
   	exit 1
fi
CURRTIME=`date '+%Y%m%d%H%M%S'`
resourceGroup=${1}
vmName=${2}
imageName=${3}
#diskEncryptionSetName=des-encrypt-set
diskEncryptionSetName="CheckMarx-HSM-Disk-Encryption-Set-Prod"
dekResourceGroup="sst-cxsast-mvp-cc"
diskEncryptionSetId=$(az disk-encryption-set show -n ${diskEncryptionSetName} -g ${dekResourceGroup} --query [id] -o tsv) && echo "diskEncryptionSetId: ${diskEncryptionSetId}"

function createVMFromImage() {
    if [ $? -eq 0 ]; then
        echo "Creating VM: ${vmName} from Image ${imageName} ..."  
        az vm create \
         --resource-group ${resourceGroup} \
         --name ${vmName} \
         --image ${imageName} \
         --admin-username adminuser \
         --vnet-name chkmrx-mvp-vnet1 \
         --subnet AppSubnet \
         --ssh-key-value ~/.ssh/chkmarx_sast_key_4096.pub \
         --os-disk-security-encryption-type DiskwithVMGuestState \
         --enable-vtpm true --enable-secure-boot true \
         --security-type ConfidentialVM \
         --os-disk-secure-vm-disk-encryption-set ${diskEncryptionSetId} \
         --os-disk-security-encryption-type DiskwithVMGuestState
    else
         echo "Creating VM: ${vmName} from Image ${imageName} ... failed ... Exiting" 
        exit 0   
    fi
}

createVMFromImage

#--os-disk-security-encryption-type DiskwithVMGuestState \
