#Create a Terraform configuration with a backend configuration block

resource "null_resource" "storage-container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "cc-nat-gw1" --account-name "confcomptfstateokweo8hp"
    EOT
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.10.0"
    }
  }
    backend "azurerm" {
        resource_group_name  = "conf-compute-tfstate"
        storage_account_name = "confcomptfstateokweo8hp"
        container_name       = "cc-nat-gw1"
        key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

terraform {
  required_version = ">=1.0"
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "bastion_subnet" {
  name                 = "${var.bastion_subnet_name}"
  virtual_network_name = "${var.virtual_network_name}"
  resource_group_name  = "${var.vnet_resource_group}"
}


resource "azurerm_public_ip" "natgwpip" {
  name                = "natgw-PIP"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "natgw1" {
  name                = "futureai-NatGateway"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "natgw-pip-associate" {
  nat_gateway_id       = azurerm_nat_gateway.natgw1.id
  public_ip_address_id = azurerm_public_ip.natgwpip.id
}

resource "azurerm_subnet_nat_gateway_association" "nat-bastion-subnet" {
  subnet_id      = data.azurerm_subnet.bastion_subnet.id
  nat_gateway_id = azurerm_nat_gateway.natgw1.id
}
