#az account set --subscription="45adad4f-3a50xxxxx-yyyyyy-zzzz"  #current_subscription_display_name  = "FUTURE-AZR_23745_OCTO_ConfidentialCompute"

#Create a Terraform configuration with a backend configuration block
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.2"
    }
  }
    backend "azurerm" {
        resource_group_name  = "cc-mhsm-tfstate"
        storage_account_name = "confcomptfstatebzbs8znh"
        container_name       = "mhsmtfstate"
        key                  = "terraform.tfstate"
    }

}
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "azurg" {
  name     = "confidential-compute-hsm"
  location = "Central US"
}

# generate a random prefix
resource "random_string" "azustring" {
  length  = 16
  special = false
  upper   = false
  number  = false

}

# Storage account to hold diag data from VMs and Azure Resources
resource "azurerm_storage_account" "azusa" {
  #name                     = random_string.azustring.result
  name                     = "${var.prefix}sa"
  resource_group_name      = azurerm_resource_group.azurg.name
  location                 = azurerm_resource_group.azurg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "CC_MVP" 
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}


#Azure Managed Hardware Security Module (Azure MHSM)

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_managed_hardware_security_module" "cckvmhsm" {
  name                       = "ccKVHsm1"
  resource_group_name        = azurerm_resource_group.azurg.name
  location                   = azurerm_resource_group.azurg.location
  sku_name                   = "Standard_B1"
  purge_protection_enabled   = true
  soft_delete_retention_days = 90
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  admin_object_ids           = [data.azurerm_client_config.current.object_id]

  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

#Azure Managed Hardware Security Module (Azure MHSM)

