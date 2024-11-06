resourceGroup="chkmarx-conf-compute-mvp"
deployName="CVM-ARM-Deployment4"
region="West US"
vmName="cvm-arm-deploy-4"

az deployment group create \
 -g ${resourceGroup} \
 -n ${deployName} \
 --template-file template.json \
 --parameters '@parameters.json'
