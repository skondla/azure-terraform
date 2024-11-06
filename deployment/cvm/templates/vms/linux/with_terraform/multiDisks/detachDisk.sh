#!/bin/bash

#az account set --subscription "23583f43-xxxx-abcd-kstr-yyyyyyyyy"

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