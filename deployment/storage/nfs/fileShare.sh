sudo mkdir /mnt/fileshare1
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/chkmarxsa.cred" ]; then
    sudo bash -c 'echo "username=chkmarxsa" >> /etc/smbcredentials/chkmarxsa.cred'
    sudo bash -c 'echo "password=<obfuscated-password, check fileshare for mount insttructions>" >> /etc/smbcredentials/chkmarxsa.cred'
fi
sudo chmod 600 /etc/smbcredentials/chkmarxsa.cred

sudo bash -c 'echo "//chkmarxsa.file.core.windows.net/fileshare1 /mnt/fileshare1 cifs nofail,credentials=/etc/smbcredentials/chkmarxsa.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30" >> /etc/fstab'
sudo mount -t cifs //chkmarxsa.file.core.windows.net/fileshare1 /mnt/fileshare1 -o credentials=/etc/smbcredentials/chkmarxsa.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30
