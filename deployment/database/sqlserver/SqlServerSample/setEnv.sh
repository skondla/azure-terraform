#!/bin/bash
export dbadminUsername=`cat ~/.secrets/sensitive.txt |grep -i dbadminUsername | awk '{print $2}'`
export dbadminPassword=`cat ~/.secrets/sensitive.txt |grep -i dbadminPassword | awk '{print $2}'`
export sqlSrvInst=mssqlserver-primary.database.windows.net
export dbPort=1433
export database=testDB
