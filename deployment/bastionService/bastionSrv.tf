#Create a Terraform configuration with a backend configuration block
resource "null_resource" "container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "ccvm-bastionsvc-tfstate" --account-name "confcomptfstateokweo8hp"
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
        container_name       = "ccvm-bastionsvc-tfstate"
        key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

# Azure load balancer module
data "azurerm_resource_group" "bastionsvc" {
  name = var.resource_group_name
}

/*
Azure Bastion Service (Azure Managed Service) and Bastion Host (VM) are two different resources. 
And AzureBastionSubnet requires a larger a large network address block (/26 or greater) and highly scalable, however waste network space.
Use Bastion Host VM as a normal VM deployment and harden security and ssh (PKI)
*/

data "azurerm_subnet" "bastionsubnet" {
  name                 = var.bastion_subnet_id
  virtual_network_name = var.virtual_network
  resource_group_name  = var.resource_group_name
}

# Public IP for Bastion
resource "azurerm_public_ip" "bastionsvc" {
  name                = "BastionSvc-pip"
  location            = data.azurerm_resource_group.bastionsvc.location
  resource_group_name = data.azurerm_resource_group.bastionsvc.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
  }
}

#Bastion Service
resource "azurerm_bastion_host" "bastionsvc" {
  name                = "BastionHost"
  location            = data.azurerm_resource_group.bastionsvc.location
  resource_group_name = data.azurerm_resource_group.bastionsvc.name

  ip_configuration {
    name                 = "ipconfig1"
    subnet_id            = data.azurerm_subnet.bastionsubnet.id
    public_ip_address_id = azurerm_public_ip.bastionsvc.id
  }
}
