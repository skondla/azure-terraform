sudo mkdir /mnt/cc-encrpted-azr-nfs-files
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/azrstorencrystor.cred" ]; then
    sudo bash -c 'echo "username=azrstorencrystor" >> /etc/smbcredentials/azrstorencrystor.cred'
    sudo bash -c 'echo "password=<obfuscated-password, check fileshare for mount insttructions>" >> /etc/smbcredentials/azrstorencrystor.cred'
fi
sudo chmod 600 /etc/smbcredentials/azrstorencrystor.cred

sudo bash -c 'echo "//azrstorencrystor.file.core.windows.net/cc-encrpted-azr-nfs-files /mnt/cc-encrpted-azr-nfs-files cifs nofail,credentials=/etc/smbcredentials/azrstorencrystor.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30" >> /etc/fstab'
sudo mount -t cifs //azrstorencrystor.file.core.windows.net/cc-encrpted-azr-nfs-files /mnt/cc-encrpted-azr-nfs-files -o credentials=/etc/smbcredentials/azrstorencrystor.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30
