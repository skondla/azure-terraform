#/bin/bash
(
echo o # Create a new empty DOS partition table
echo n # Add a new partition
echo p # Primary partition
echo 1 # Partition number
echo   # First sector (Accept default: 1)
echo   # Last sector (Accept default: varies)
echo w # Write changes
) | sudo fdisk /dev/sdb

sudo mke2fs -t ext4 /dev/sdb1
#sudo mkfs -t ext4 /dev/sdb1
sudo mkdir /data1
sudo mount -t ext4 /dev/sdb1 /data1
sudo mkdir -p /data1/app
sudo chown -R adminuser:adminuser /data1/app
echo "/dev/sdb1       /data1  ext4    defaults,discard        0 1" | sudo tee -a /etc/fstab

