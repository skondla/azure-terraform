#Create a Terraform configuration with a backend configuration block

resource "null_resource" "storage-container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "cc-azrfiles-tfstate" --account-name "confcomptfstateokweo8hp"
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
        container_name       = "cc-azrfiles-tfstate"
        key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

terraform {
  required_version = ">=1.0"
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_disk_encryption_set" "des" {
  name                = "${var.confidentialDiskEncryptionSetId}"
  resource_group_name = var.resource_group_name_des
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


#Manages a Subnet Service Endpoint Storage Policy.
resource "azurerm_subnet_service_endpoint_storage_policy" "ccstoragepolicy" {
  name                                = "cc-storage-policy"
  resource_group_name                 = data.azurerm_resource_group.rg.name
  location                            = data.azurerm_resource_group.rg.location
  definition {
    name        = "cc-storage-policy-def1"
    description = "storage-policy-def1"
    service_resources = [
      data.azurerm_resource_group.rg.id,
      azurerm_storage_account.azusafiles.id
    ]
  }
}

# create private DNS zone
resource "azurerm_private_dns_zone" "storage_dns_pe" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Storage account to hold diag data from VMs and Azure Resources
resource "azurerm_storage_account" "azusafiles" {
  name                                = "${var.prefix}safiles"
  resource_group_name                 = data.azurerm_resource_group.rg.name
  location                            = data.azurerm_resource_group.rg.location
  account_tier                        = "Standard"
  account_replication_type            = "LRS"
  #account_kind                        = "FileStorage"
  nfsv3_enabled                       = var.nfsv3_enabled
  enable_https_traffic_only           = var.enable_https_traffic_only
  min_tls_version                     = var.min_tls_version
  large_file_share_enabled            = var.large_file_share_enabled
  infrastructure_encryption_enabled   = var.infrastructure_encryption_enabled
  is_hns_enabled                      = var.is_hns_enabled
  #deploy_private_endpoint             = true
  #pe_subnet_id                        = data.azurerm_subnet.pe_subnet.id
  #private_dns_zone        = {
  #  name = azurerm_private_dns_zone.storage_dns_pe.name
  #  id   = azurerm_private_dns_zone.storage_dns_pe.id
  #}

  #private_dns_zone        = {
  #  name = "privatelink.file.core.windows.net"
  #  id   = "h5jqmLtnbKnRn2pdgyAZqpBm4pVGc5x+yGbesxTIPVw="
  #}

  tags = {
    environment = "CC_MVP" 
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
  #depends_on = [
  #  azurerm_storage_container.data
  #]
  /*
  provisioner "local-exec" {
    command =<<EOT
    az storage share create \
     --account-name ${azurerm_storage_account.azusafiles.name} \
     --name ${var.myshare_nfs} \
     --quota 100   
    EOT
  }
  provisioner "local-exec" {
    command =<<EOT
    az storage share create \
     --account-name ${azurerm_storage_account.azusafiles.name} \
     --name ${var.myshare_smb} \
     --quota 100   
    EOT
    #interpreter = [ "Powershell", "-c"]
  }
  */

}

