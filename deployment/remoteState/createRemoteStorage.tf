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

resource "azurerm_resource_group" "tfstate" {
  name     = "conf-compute-tfstate"
  location = "West US"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "confcomptfstate${random_string.resource_code.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true

  tags = {
    environment = "development"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "cxtfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "blob"
}

output "storage_account_name" {
  value = azurerm_storage_container.tfstate.storage_account_name
  description = "The storage account name for tfstate."
}
