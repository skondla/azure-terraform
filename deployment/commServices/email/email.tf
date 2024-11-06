#Create a Terraform configuration with a backend configuration block

resource "null_resource" "storage-container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "cc-email-tfstate" --account-name "confcomptfstateokweo8hp"
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
        container_name       = "cc-email-tfstate"
        key                  = "terraform.tfstate"
    }
}


provider "azurerm" {
  features {}
}

terraform {
  required_version = ">=1.0"
}


# Azure load balancer module
data "azurerm_resource_group" "email-rg" {
  name = var.resource_group_name
}

resource "azurerm_communication_service" "email-rg" {
  name                = "cc-email-comm-service"
  resource_group_name = data.azurerm_resource_group.email-rg.name
  data_location       = "United States"
}

