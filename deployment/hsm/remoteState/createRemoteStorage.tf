terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_string" "resource_code" {
  length  = 8
  special = false
  upper   = false
}
/*
resource "azurerm_subscription" "cchsm" {
  subscription_name = "FUTURE-AZR_23745_OCTO_ConfidentialCompute"
  subscription_id   = "45adad4f-3a50xxxxx-yyyyyy-zzzz"
}
*/
data "azurerm_subscription" "current" {
}

output "current_subscription_display_name" {
  value = data.azurerm_subscription.current.display_name
}

resource "azurerm_resource_group" "tfstate" {
  name     = "cc-mhsm-tfstate"
  location = "Central US"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "confcomptfstate${random_string.resource_code.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "development"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "mhsmtfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "blob"
}

output "storage_account_name" {
  value = azurerm_storage_container.tfstate.storage_account_name
  description = "The storage account name for tfstate."
}
