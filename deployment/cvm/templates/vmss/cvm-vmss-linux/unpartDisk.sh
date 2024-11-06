#!/bin/bash
sudo umount /data1 
sudo rm -rf /data1

(
echo m # help
echo d # Delete an existing partition
echo w # Write changes
) | sudo fdisk /dev/sdb
sudo wipefs -f /dev/sdb
sudo sed -i '/sdb1/d' /etc/fstab
