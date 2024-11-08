#!/bin/bash

#Establish a private link connection to Managed HSM using CLI (Initial Setup)

#Populate the env variables
SUBSCRIPTION_ID="23583f43-xxxx-abcd-kstr-yyyyyyyyy"
APP_RESOURCE_GROUP="cc-hsm-prvlink-integ"
NET_RESOURCE_GROUP="futurepnet"
REGION="westus"
HSM_NAME="ccKVHsm1"
HSM_RG_NAME="confidential-compute-hsm"
CHKMARX_VNET_NAME="checkmarx-vnet-1"
CHKMARX_SUBNET_NAME="privlnkSubnet"
CHKMARX_SUBNET_ADDR_CIDR="172.21.36.64/28"
DNS_ZONE_LINK_NAME="chkmarx_dns_zone_link"
PRIV_LINK_CONN_NAME="chkmarx_priv_link_conn"
PRIVATE_END_POINT="chkmarx_prv_ep1"

az login                                                                   # Login to Azure CLI
az account set --subscription ${SUBSCRIPTION_ID}                          # Select your Azure Subscription
az group create -n ${APP_RESOURCE_GROUP} -l ${REGION}                            # Create a new Resource Group
az provider register -n Microsoft.KeyVault                                 # Register KeyVault as a provider
az keyvault update-hsm --hsm-name ${HSM_NAME} -g ${HSM_RG_NAME} --default-action deny # Turn on firewall

#az network vnet create -g ${RESOURCE_GROUP} -n ${VNET_NAME} --location ${REGION}           # Create a Virtual Network

    # Create a Subnet
az network vnet subnet create -g ${NET_RESOURCE_GROUP} --vnet-name ${CHKMARX_VNET_NAME} --name ${CHKMARX_SUBNET_NAME} --address-prefixes ${CHKMARX_SUBNET_ADDR_CIDR}

# Disable Virtual Network Policies
az network vnet subnet update --name ${CHKMARX_SUBNET_NAME} --resource-group ${NET_RESOURCE_GROUP} --vnet-name ${CHKMARX_VNET_NAME} --disable-private-endpoint-network-policies true

# Create a Private DNS Zone
#az network private-dns zone create --resource-group ${APP_RESOURCE_GROUP} --name privatelink.managedhsm.azure.net  #this gets created in ${APP_RESOURCE_GROUP}
az network private-dns zone create --resource-group ${NET_RESOURCE_GROUP} --name privatelink.managedhsm.azure.net  #this gets created in ${APP_RESOURCE_GROUP}

# Link the Private DNS Zone to the Virtual Network
az network private-dns link vnet create --resource-group ${NET_RESOURCE_GROUP} --virtual-network ${CHKMARX_VNET_NAME}  --zone-name privatelink.managedhsm.azure.net --name ${DNS_ZONE_LINK_NAME} --registration-enabled true

#Allow trusted services to access Managed HSM

az keyvault update-hsm --hsm-name ${HSM_NAME} -g ${HSM_RG_NAME} --default-action deny --bypass AzureServices

#Create a Private Endpoint (Automatically Approve)

az network private-endpoint create \
 --resource-group ${APP_RESOURCE_GROUP} \
 --vnet-name ${CHKMARX_VNET_NAME} \
 --subnet ${CHKMARX_SUBNET_NAME} \
 --name ${PRIVATE_END_POINT}  \
 --private-connection-resource-id "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${APP_RESOURCE_GROUP}/providers/Microsoft.KeyVault/managedHSMs/${HSM_NAME}" \
 --group-id managedhsm --connection-name ${PRIV_LINK_CONN_NAME} --location ${REGION}


# az network private-endpoint create \
#  --resource-group ${APP_RESOURCE_GROUP} \
#  --vnet-name ${CHKMARX_VNET_NAME} \
#  --subnet ${CHKMARX_SUBNET_NAME} \
#  --name ${PRIVATE_END_POINT}  \
#  --private-connection-resource-id "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${HSM_RG_NAME}/providers/Microsoft.KeyVault/managedHSMs/${HSM_NAME}" \
#  --group-id managedhsm --connection-name ${PRIV_LINK_CONN_NAME} --location ${REGION}

#Manage Private Link Connections

# Show Connection Status
az network private-endpoint show --resource-group ${APP_RESOURCE_GROUP} --name ${PRIVATE_END_POINT}

# Approve a Private Link Connection Request
az keyvault private-endpoint-connection approve --description "Approve chkmarx private endpoint connection" --resource-group ${APP_RESOURCE_GROUP} --hsm-name ${HSM_NAME} –-name ${PRIV_LINK_CONN_NAME}

# Deny a Private Link Connection Request
az keyvault private-endpoint-connection reject --description {"Reject chkmarx private endpoint connection"} --resource-group ${APP_RESOURCE_GROUP} --hsm-name ${HSM_NAME}  –-name ${PRIV_LINK_CONN_NAME}

# Delete a Private Link Connection Request
az keyvault private-endpoint-connection delete --resource-group ${APP_RESOURCE_GROUP} --hsm-name ${HSM_NAME} --name ${PRIV_LINK_CONN_NAME}
