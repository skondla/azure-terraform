#!/bin/bash

#az account set --subscription "7157c5e7-0f06-458b-8229-0a0f52209ee2"

if [ $# -lt 3 ];
then
	echo "USAGE: $0 <options {resourceGroup, vmName, diskName}>"
   	exit 1
fi
resourceGroup=${1}
vmName=${2}
diskName=${3}

az vm disk detach \
 -g ${resourceGroup} \
 --vm-name ${vmName} \
 -n ${diskName}