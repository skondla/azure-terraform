#!/bin/bash

if [ $# -lt 1 ];
then
	echo "USAGE: $0 <upgrade option> [start|cancel|get-latest]"
	exit 1
fi

upgrOption=${1}

az vmss rolling-upgrade ${upgrOption} -n cc-win -g chkmarx-conf-compute-mvp
