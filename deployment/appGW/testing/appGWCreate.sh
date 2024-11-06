#Create Resource Group:

az group create --name testRGAppGW --location westus

#Create Network Resources

az network vnet create \
  --name myVNet \
  --resource-group testRGAppGW \
  --location westus \
  --address-prefix 10.21.0.0/16 \
  --subnet-name myAGSubnet \
  --subnet-prefix 10.21.0.0/24
az network vnet subnet create \
  --name myBackendSubnet \
  --resource-group testRGAppGW \
  --vnet-name myVNet   \
  --address-prefix 10.21.1.0/24
az network public-ip create \
  --resource-group testRGAppGW \
  --name myAGPublicIPAddress \
  --allocation-method Static \
  --sku Standard


#Backend Servers

#Create two VMs for backend servers

cat <<EOF > cloud-init.txt
#cloud-config
package_upgrade: true
packages:
  - nginx
  - nodejs
  - npm
write_files:
  - owner: www-data:www-data
  - path: /etc/nginx/sites-available/default
    content: |
      server {
        listen 80;
        location / {
          proxy_pass http://localhost:3000;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection keep-alive;
          proxy_set_header Host $host;
          proxy_cache_bypass $http_upgrade;
        }
      }
  - owner: azureuser:azureuser
  - path: /home/azureuser/myapp/index.js
    content: |
      var express = require('express')
      var app = express()
      var os = require('os');
      app.get('/', function (req, res) {
        res.send('Hello World from host ' + os.hostname() + '!')
      })
      app.listen(3000, function () {
        console.log('Hello world app listening on port 3000!')
      })
runcmd:
  - service nginx restart
  - cd "/home/azureuser/myapp"
  - npm init
  - npm install express -y
  - nodejs index.js
EOF

#Create VMs:

for i in `seq 1 2`; do
  az network nic create \
    --resource-group testRGAppGW \
    --name myNic$i \
    --vnet-name myVNet \
    --subnet myBackendSubnet
  az vm create \
    --resource-group testRGAppGW \
    --name myVM$i \
    --nics myNic$i \
    --image UbuntuLTS \
    --admin-username azureuser \
    --generate-ssh-keys \
    --custom-data cloud-init.txt
done

#Create Application Gateway

address1=$(az network nic show --name myNic1 --resource-group testRGAppGW | grep "\"privateIpAddress\":" | grep -oE '[^ ]+$' | tr -d '",')
address2=$(az network nic show --name myNic2 --resource-group testRGAppGW | grep "\"privateIpAddress\":" | grep -oE '[^ ]+$' | tr -d '",')
az network application-gateway create \
  --name myAppGateway \
  --location westus \
  --resource-group testRGAppGW \
  --capacity 2 \
  --sku Standard_v2 \
  --public-ip-address myAGPublicIPAddress \
  --vnet-name myVNet \
  --subnet myAGSubnet \
  --servers "$address1" "$address2"

#Test Application Gateway

az network public-ip show \
  --resource-group testRGAppGW \
  --name myAGPublicIPAddress \
  --query [ipAddress] \
  --output tsv

#Clean Up Resource Group

#az group delete --name testRGAppGW

