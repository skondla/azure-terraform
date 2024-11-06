#Create a Terraform configuration with a backend configuration block

resource "null_resource" "test" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n cc-sqlsrvdb-tfstate --account-name "confcomptfstateokweo8hp" 
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
        container_name       = "cc-sqlsrvdb-tfstate"
        key                  = "terraform.tfstate"
    }

}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  #location  = var.location
}

data "azurerm_storage_account" "storagaacct" {
  name                = var.storage_account
  resource_group_name = var.resource_group_name
  #account_tier             = "Standard"
  #account_replication_type = "LRS"
}

output "storage_account_tier" {
  value = data.azurerm_storage_account.storagaacct.account_tier
}

/*
resource "azurerm_storage_account" "cxsqlstorage" {
  name                      = "cx1sqlsrvdbsa"
  resource_group_name       = data.azurerm_resource_group.rg.name
  location                  = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
*/

resource "azurerm_mssql_server" "cxsqlsrvprimary" {
  name                         = "mssqlserver-primary"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.dbadminUsername
  administrator_login_password = var.dbadminPassword
}

resource "azurerm_mssql_server" "cxsqlsrvstandby" {
  name                         = "mssqlserver-secondary"
  resource_group_name          = var.resource_group_name
  location                     = var.secondary_location
  version                      = "12.0"
  administrator_login          = var.dbadminUsername
  administrator_login_password = var.dbadminPassword
}

resource "azurerm_mssql_database" "cxsqlsrvdb" {
  name           = "cxsqlsrvdb1"
  server_id      = azurerm_mssql_server.cxsqlsrvprimary.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 1024
  read_scale     = true
  #sku_name       = "P1" #https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-dtu-single-databases?view=azuresql
  sku_name       = "P1"
  #sku_name       = "GP_DC_2"
  #zone_redundant = true

} 

resource "azurerm_mssql_failover_group" "cxsqlfailovergrp" {
  name      = "cxsqlfailovergrp"
  server_id = azurerm_mssql_server.cxsqlsrvprimary.id
  databases = [
    azurerm_mssql_database.cxsqlsrvdb.id
  ]

  partner_server {
    id = azurerm_mssql_server.cxsqlsrvstandby.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }

  tags = {
    owner = var.owner
    cost_center_name = var.cost_center_name
    cost_center_code = var.cost_center_code
  }
}