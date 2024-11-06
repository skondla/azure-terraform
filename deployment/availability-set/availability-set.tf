#Create a Terraform configuration with a backend configuration block
resource "null_resource" "storage-container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "cvm-availability-set-tfstate" --account-name "confcomptfstateokweo8hp"
    EOT
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.8"
    }
  }
    backend "azurerm" {
        resource_group_name  = "conf-compute-tfstate"
        storage_account_name = "confcomptfstateokweo8hp"
        container_name       = "cvm-availability-set-tfstate"
        key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

terraform {
  required_version = ">=1.0"
}

resource "azurerm_availability_set" "cxaset" {
  name                  = "${var.prefix}-az-set-1"
  resource_group_name   = "${var.resource_group_name}"
  location              = "${var.location}"

  tags = {
    environment = "MVP"
  }
}




