#!/bin/sh
sudo apt update
sudo apt install net-tools
IPADDR=`ifconfig -a|grep broadcast | awk '{print $2}'`
HOSTNAME=`hostname`".pdsea.futurenet.com"
sudo echo "${IPADDR} ${HOSTNAME} `hostname`" >> /etc/hosts
sudo hostnamectl set-hostname ${HOSTNAME}

#replace nginx /etc/nginx/sites-available/default
#copy web server certificate to /etc/ssl/certs/
#copy web server key to /etc/ssl/private/

#restart nginx
#sudo service nginx restart
#sudo service nginx status
