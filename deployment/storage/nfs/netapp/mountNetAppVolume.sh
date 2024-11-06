#!/bin/bash
#Purpose: Mount netapp volume on VM

#skondla@C02G1085MD6R:~$ ssh -i ~/.ssh/chkmarx_sast_key_4096 adminuser@172.21.39.134

sudo apt update
sudo apt-get install nfs-common -y
sudo mkdir /netappvol1
sudo mount -t nfs -o rw,hard,rsize=65536,wsize=65536,vers=3,tcp 172.21.39.76:/azrnetappfilepath /netappvol1
df -h
sudo mkdir -p /netappvol1/nfsshare
sudo chown -R adminuser:adminuser /netappvol1/nfsshare
sudo chmod 755 /netappvol1/nfsshare/
