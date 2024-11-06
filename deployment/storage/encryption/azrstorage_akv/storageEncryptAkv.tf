
#Create a Terraform configuration with a backend configuration block

resource "null_resource" "storage-container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "cc-azrstorencry" --account-name "confcomptfstateokweo8hp"
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
        container_name       = "cc-azrstorencry"
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

data "azurerm_resource_group" "azrstorencry" {
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

resource "azurerm_key_vault" "azrstorencry" {
  name                = "azrstorencrykv"
  location            = data.azurerm_resource_group.azrstorencry.location
  resource_group_name = data.azurerm_resource_group.azrstorencry.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id = azurerm_key_vault.azrstorencry.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_storage_account.azrstorencry.identity.0.principal_id

  key_permissions    = ["Get", "Create", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

resource "azurerm_key_vault_access_policy" "client" {
  key_vault_id = azurerm_key_vault.azrstorencry.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}


resource "azurerm_key_vault_key" "azrstorencry" {
  name         = "tfex-key"
  key_vault_id = azurerm_key_vault.azrstorencry.id
  key_type     = "RSA"
  key_size     = 4096
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.client,
    azurerm_key_vault_access_policy.storage,
  ]
}


resource "azurerm_storage_account" "azrstorencry" {
  name                     = "azrstorencrystor"
  resource_group_name      = data.azurerm_resource_group.azrstorencry.name
  location                 = data.azurerm_resource_group.azrstorencry.location
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
  #deploy_private_endpoint             = true
  #pe_subnet_id                        = data.azurerm_subnet.pe_subnet.id

  #private_dns_zone        = {
  #  name = "privatelink.file.core.windows.net"
  #  id   = "h5jqmLtnbKnRn2pdgyAZqpBm4pVGc5x+yGbesxTIPVw="
  #}

  tags = {
    environment = "confidential-computing-prod" 
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }

  network_rules {
    default_action                  = "Deny"
    bypass                          = ["AzureServices"]
    #ip_rules                        = [var.vnet_cidr_block]
    #ip_rules                        = "172.21.39.0/24"
    virtual_network_subnet_ids      = [data.azurerm_subnet.app_subnet.id,data.azurerm_subnet.db_subnet.id,data.azurerm_subnet.bastion_subnet.id,data.azurerm_subnet.pe_subnet.id]
    #private_link_access {}
  }
}

resource "azurerm_storage_account_customer_managed_key" "azrstorencry" {
  storage_account_id = azurerm_storage_account.azrstorencry.id
  key_vault_id       = azurerm_key_vault.azrstorencry.id
  key_name           = azurerm_key_vault_key.azrstorencry.name
}

