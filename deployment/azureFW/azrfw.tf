#Create a Terraform configuration with a backend configuration block
resource "null_resource" "container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "ccvm-azrfw-tfstate" --account-name "confcomptfstateokweo8hp"
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
        container_name       = "ccvm-azrfw-tfstate"
        key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

# Azure load balancer module
data "azurerm_resource_group" "azrfw" {
  name = var.resource_group_name
}

data "azurerm_subnet" "azrfwsubnet" {
  name                 = var.subnet_id
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

output "subnet_id" {
  value = data.azurerm_subnet.azrfwsubnet.id
}

# Public IP for Azure Firewall
resource "azurerm_public_ip" "azufwpip" {
  name                = "azureFirewalls-pip"
  resource_group_name = data.azurerm_resource_group.azrfw.name
  location            = data.azurerm_resource_group.azrfw.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = var.environment
    owner       = var.owner
    cost_center_name  = var.cost_center_name
    cost_center_code  = var.cost_center_code
  }
}

# Azure Firewall
resource "azurerm_firewall" "azufw" {
  name                = "firewall1"
  resource_group_name = data.azurerm_resource_group.azrfw.name
  location            = data.azurerm_resource_group.azrfw.location
  #sku_tier            = "Premium"
  sku_tier            = "Standard"
  #sku_name            = "AZFW_Hub"
  sku_name            = "AZFW_VNet"
  ip_configuration {
    name                 = "configuration"
    #subnet_id            = var.subnet_id
    subnet_id            = data.azurerm_subnet.azrfwsubnet.id 
    public_ip_address_id = azurerm_public_ip.azufwpip.id
  }
}

# Azure Firewall Application Rule
resource "azurerm_firewall_application_rule_collection" "azufwappr1" {
  name                = "appRc1"
  azure_firewall_name = azurerm_firewall.azufw.name
  resource_group_name = data.azurerm_resource_group.azrfw.name
  priority            = 101
  action              = "Allow"

  rule {
    name = "appRule1"

    source_addresses = [
      #"10.29.0.0/29",
      "*",
    ]

    target_fqdns = [
      "*.microsoft.com","*.future.ai.com","*.future.ainet.com"
    ]

    protocol {
      port = "443"
      type = "Https"
     }
  }
}

#VWAN/VHub as a transit gateway

resource "azurerm_virtual_wan" "vwan" {
  name                = "cc-vwan1"
  resource_group_name = data.azurerm_resource_group.azrfw.name
  location            = data.azurerm_resource_group.azrfw.location
}

resource "azurerm_virtual_hub" "vhub" {
  name                = "cc-hub1"
  resource_group_name = data.azurerm_resource_group.azrfw.name
  location            = data.azurerm_resource_group.azrfw.location
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = "172.21.39.0/24"
}


# Azure Firewall Network Rule
resource "azurerm_firewall_network_rule_collection" "azufwnetr1" {
  name                = "fwrulecollection"
  azure_firewall_name = azurerm_firewall.azufw.name
  resource_group_name = data.azurerm_resource_group.azrfw.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "netRc1"

    source_addresses = [
      #"10.29.0.0/29",
      "*",
    ]

    destination_ports = [
      "8000-8999",
    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "TCP",
    ]
  }
}

#Azure Firewall NAT Rule 

resource "azurerm_firewall_nat_rule_collection" "natrulecollect" {
  name                = "natrule1"
  azure_firewall_name = azurerm_firewall.azufw.name
  resource_group_name = data.azurerm_resource_group.azrfw.name
  priority            = 100
  action              = "Dnat"

  rule {
    name = "natrule1"

    source_addresses = [
      #"10.29.0.0/19",
      "*",
    ]

    destination_ports = [
      "53",
    ]

    destination_addresses = [
      azurerm_public_ip.azufwpip.ip_address
    ]

    translated_port = 53

    translated_address = "8.8.8.8"
    #translated_address = "192.168.76.180"
    #translated_address = ["172.23.241.180","172.23.241.181"]

    protocols = [
      "TCP",
      "UDP",
    ]
  }
}
