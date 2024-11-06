#!/bin/bash
#Purpose: Mount Azure Files share on Linux host

sudo mkdir /mnt/cc-azr-nfs-files
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/chkmarxsafiles.cred" ]; then
    sudo bash -c 'echo "username=chkmarxsafiles" >> /etc/smbcredentials/chkmarxsafiles.cred'
    sudo bash -c 'echo "password=<obfuscated-password, check fileshare for mount insttructions>" >> /etc/smbcredentials/chkmarxsafiles.cred'
fi
sudo chmod 600 /etc/smbcredentials/chkmarxsafiles.cred

sudo bash -c 'echo "//chkmarxsafiles.file.core.windows.net/cc-azr-nfs-files /mnt/cc-azr-nfs-files cifs nofail,credentials=/etc/smbcredentials/chkmarxsafiles.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30" >> /etc/fstab'
sudo mount -t cifs //chkmarxsafiles.file.core.windows.net/cc-azr-nfs-files /mnt/cc-azr-nfs-files -o credentials=/etc/smbcredentials/chkmarxsafiles.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30
