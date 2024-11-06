resource "null_resource" "storage-container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "cc-attestation-tfstate" --account-name "confcomptfstateokweo8hp"
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
        container_name       = "cc-attestation-tfstate"
        key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 0.14"
}

resource "azurerm_attestation_provider" "cc-Attestation" {
    name                              = var.attestation_provider_name
    resource_group_name               = var.resource_group_name
    location                          = var.resource_group_location

    policy_signing_certificate_data   = file(var.policy_file)
}