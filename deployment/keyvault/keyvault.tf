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
        container_name       = "sastkvtfstate"
        key                  = "terraform.tfstate"
    }

}
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "azurg" {
  name     = "cc-hsm-prvlink-integ"
  location = "West US"
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
#data "azurerm_client_config" "current" {}
/*
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
*/
#Azure Managed Hardware Security Module (Azure MHSM)

#KV Disk Encription Set

data "azurerm_client_config" "current" {}

output "account_id" {
  value = data.azurerm_client_config.current.client_id
}


resource "azurerm_key_vault" "kvaultcc2" {
  name                        = "des-sast-keyvault-cc5"
  location                    = azurerm_resource_group.azurg.location
  resource_group_name         = azurerm_resource_group.azurg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true

    access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "Create",
      "Delete",
      "Get",
      "Import",
      "List",
      "Update"
    ]

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey"
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set"
    ]
  }
}

#Azure KeyVault Certificate
resource "azurerm_key_vault_certificate" "azrkvcert" {
  name         = "kv-cert2"
  key_vault_id = azurerm_key_vault.kvaultcc2.id

  certificate {
    contents = filebase64("appGWCert/appgwcert.pfx")
    password = var.sslExportPasswd
  }
}

resource "azurerm_key_vault_key" "kvkey2" {
  name         = "des-keyvault-key2"
  key_vault_id = azurerm_key_vault.kvaultcc2.id
  key_type     = "RSA"
  key_size     = 2048

  depends_on = [
    azurerm_key_vault_access_policy.kv-access-user-2
  ]

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_disk_encryption_set" "encryptset" {
  name                = "des-encrypt-set"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  key_vault_key_id    = azurerm_key_vault_key.kvkey2.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "encrypt-disk" {
  key_vault_id = azurerm_key_vault.kvaultcc2.id

  tenant_id = azurerm_disk_encryption_set.encryptset.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.encryptset.identity.0.principal_id
  /*
  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ] */

  certificate_permissions = [
      "Create",
      "Delete",
      "Get",
      "Import",
      "List",
      "Update"
    ]

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey"
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set"
    ]
}

resource "azurerm_key_vault_access_policy" "kv-access-user-2" {
  key_vault_id = azurerm_key_vault.kvaultcc2.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
  /*
  key_permissions = [
    "Get",
    "Create",
    "Delete"
  ] */
  certificate_permissions = [
      "Create",
      "Delete",
      "Get",
      "Import",
      "List",
      "Update"
    ]

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey"
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set"
    ]
}


