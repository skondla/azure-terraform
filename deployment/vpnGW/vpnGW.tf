#Create a Terraform configuration with a backend configuration block

resource "null_resource" "test" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n cc-vpngw-tfstate --account-name "confcomptfstateokweo8hp" 
    EOT
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.2"
    }
  }
    backend "azurerm" {
        resource_group_name  = "conf-compute-tfstate"
        storage_account_name = "confcomptfstateokweo8hp"
        container_name       = "cc-vpngw-tfstate"
        key                  = "terraform.tfstate"
    }

}

provider "azurerm" {
  features {}
}

# Azure Application Gateway module
data "azurerm_resource_group" "vpngwrg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "appgwnet" {
  name = var.virtual_network
  resource_group_name  = var.resource_group_name
}

output "virtual_network_id" {
  value = data.azurerm_virtual_network.appgwnet.id
}


/*
Virtual WAN, VPN Gateway within a Virtual Hub, which enables Site-to-Site communication are moved to a sub-directory under deployment/vpnGW 
and can either be deployed as part of landing zone or a seperate add on deployment. 
*/


#Virtual WAN, VPN Gateway within a Virtual Hub, which enables Site-to-Site communication

resource "azurerm_virtual_wan" "vwan" {
  name                = "cc-vwan1"
  resource_group_name = data.azurerm_resource_group.vpngwrg.name
  location            = data.azurerm_resource_group.vpngwrg.location
}

resource "azurerm_virtual_hub" "vhub" {
  name                = "cc-hub1"
  resource_group_name = data.azurerm_resource_group.vpngwrg.name
  location            = data.azurerm_resource_group.vpngwrg.location
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = var.vnet_address_prefix
}


resource "azurerm_vpn_gateway" "vpngw1" {
  name                = "cc-vpngw1"
  location            = data.azurerm_resource_group.vpngwrg.location
  resource_group_name = data.azurerm_resource_group.vpngwrg.name
  virtual_hub_id      = azurerm_virtual_hub.vhub.id
}
