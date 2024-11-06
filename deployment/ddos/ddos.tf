#Create a Terraform configuration with a backend configuration block
resource "null_resource" "container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "ccvm-azrddos-tfstate" --account-name "confcomptfstateokweo8hp"
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
        container_name       = "ccvm-azrddos-tfstate"
        key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

# Azure load balancer module
data "azurerm_resource_group" "ddos" {
  name = var.resource_group_name
}

#DDoS Protection Plan

resource "azurerm_network_ddos_protection_plan" "azrddos" {
  name                  = "ddos-protection-plan"
  resource_group_name   = data.azurerm_resource_group.ddos.name
  location              = data.azurerm_resource_group.ddos.location
}

data "azurerm_network_ddos_protection_plan" "azrddos" {
  name                = azurerm_network_ddos_protection_plan.azrddos.name
  resource_group_name = azurerm_network_ddos_protection_plan.azrddos.resource_group_name
}

output "ddos_protection_plan_id" {
  value = data.azurerm_network_ddos_protection_plan.azrddos.id
}

