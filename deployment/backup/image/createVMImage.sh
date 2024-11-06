#!/bin/bash -x
#Purpose: Create custom Image from VM


#az account set --subscription "7157c5e7-0f06-458b-8229-0a0f52209ee2"

if [ $# -lt 2 ];
then
	echo "USAGE: $0 <options {resourceGroup, vmName}>"
   	exit 1
fi
CURRTIME=`date '+%Y%m%d%H%M%S'`
resourceGroup=${1}
vmName=${2}
imageName=${vmName}-image-${CURRTIME}

function deallocate() {
    if [ $? -eq 0 ]; then
        echo "VM: ${vmName} deallocation starting...."
        az vm deallocate \
         --resource-group ${resourceGroup} \
         --name ${vmName} 
    else
        echo "VM: ${vmName} failed to deallocate VM.... Exiting"
        exit 0     
    fi
}


function generalize() {
    if [ $? -eq 0 ]; then
        echo "VM: ${vmName} generalize starting...."
        az vm generalize \
         --resource-group ${resourceGroup} \
         --name ${vmName} 
    else
        echo "VM: ${vmName} failed to generalize VM.... Exiting"  
        exit 0  
    fi
}

function imageCreate() {
    if [ $? -eq 0 ]; then
         echo "Image ${imageName} for VM: ${vmName} starting..."  
        az image create \
         --resource-group ${resourceGroup} \
         --name ${imageName} \
         --source ${vmName} \
         --hyper-v-generation V2 
         #--zone-resilient true
    else
        echo "Image ${imageName} for VM: ${vmName} failed ... Exiting"  
        exit 0   
    fi
}

deallocate
generalize
imageCreate