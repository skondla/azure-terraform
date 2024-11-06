
#Create a Terraform configuration with a backend configuration block

resource "null_resource" "storage-container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "cc-azrstormhsmencry-mhsm" --account-name "confcomptfstateokweo8hp"
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
        container_name       = "cc-azrstormhsmencry-mhsm"
        key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

terraform {
  required_version = ">=1.0"
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "azrstormhsmencry" {
  name = var.resource_group_name
}

data "azurerm_subnet" "app_subnet" {
  name                 = "${var.app_subnet_name}"
  virtual_network_name = "${var.virtual_network_name}"
  resource_group_name  = "${var.vnet_resource_group}"
}

data "azurerm_subnet" "db_subnet" {
  name                 = "${var.db_subnet_name}"
  virtual_network_name = "${var.virtual_network_name}"
  resource_group_name  = "${var.vnet_resource_group}"
}

data "azurerm_subnet" "bastion_subnet" {
  name                 = "${var.bastion_subnet_name}"
  virtual_network_name = "${var.virtual_network_name}"
  resource_group_name  = "${var.vnet_resource_group}"
}

data "azurerm_subnet" "pe_subnet" {
  name                 = "${var.pe_subnet_name}"
  virtual_network_name = "${var.virtual_network_name}"
  resource_group_name  = "${var.vnet_resource_group}"
}

data "azurerm_disk_encryption_set" "des" {
  name                = "${var.confidentialDiskEncryptionSetId}"
  resource_group_name = var.resource_group_name_des
}

resource "azurerm_storage_account" "azrstormhsmencry" {
  name                     = "azrstormhsmencry"
  resource_group_name      = data.azurerm_resource_group.azrstormhsmencry.name
  location                 = data.azurerm_resource_group.azrstormhsmencry.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned"
  }
  nfsv3_enabled                       = var.nfsv3_enabled
  enable_https_traffic_only           = var.enable_https_traffic_only
  min_tls_version                     = var.min_tls_version
  large_file_share_enabled            = var.large_file_share_enabled
  infrastructure_encryption_enabled   = var.infrastructure_encryption_enabled
  is_hns_enabled                      = var.is_hns_enabled

  tags = {
    environment = "confidential-computing-prod" 
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }

  network_rules {
    default_action                  = "Deny"
    bypass                          = ["AzureServices"]
    virtual_network_subnet_ids      = [data.azurerm_subnet.app_subnet.id,data.azurerm_subnet.db_subnet.id,data.azurerm_subnet.bastion_subnet.id,data.azurerm_subnet.pe_subnet.id]
  }
}

/*
resource "azurerm_storage_account_customer_managed_key" "azrstormhsmencry" {
  storage_account_id = azurerm_storage_account.azrstormhsmencry.id
  key_vault_id       = data.azurerm_disk_encryption_set.des.id
  key_name           = data.azurerm_disk_encryption_set.des.name
}
*/
