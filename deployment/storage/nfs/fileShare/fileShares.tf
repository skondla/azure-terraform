
#Create a Terraform configuration with a backend configuration block

resource "null_resource" "storage-container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "cc-fileshares-tfstate" --account-name "confcomptfstateokweo8hp"
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
        container_name       = "cc-fileshares-tfstate"
        key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

terraform {
  required_version = ">=1.0"
}

data "azurerm_storage_account" "storagaacct" {
  name                = var.storage_account
  resource_group_name = var.resource_group_name
}

output "storage_account_tier" {
  value = data.azurerm_storage_account.storagaacct.account_tier
}

resource "azurerm_storage_share" "azrfiles-nfs" {
  name                 = "cc-azr-nfs-files"
  storage_account_name = data.azurerm_storage_account.storagaacct.name
  quota                = 50
  enabled_protocol     = "NFS"

  acl {
    id = "dT3TxaheeL25ei0kDpPqS1cHUMv6vAnOKJ6SKBF2nJQ="

    access_policy {
      permissions = "rwdl"
      start       = "2022-08-15T09:38:21.0000000Z"
      expiry      = "2023-08-15T10:38:21.0000000Z"
    }
  }
  depends_on      = [data.azurerm_storage_account.storagaacct]
}


resource "azurerm_storage_share" "azrfiles-smb" {
  name                 = "cc-azr-smb-files"
  storage_account_name = data.azurerm_storage_account.storagaacct.name
  quota                = 50
  enabled_protocol     = "SMB"

  acl {
    id = "wiC3ENrYVcZjb9T0LRphhTCq2jnJ1CLCgE/omTYWNpE="

    access_policy {
      permissions = "rwdl"
      start       = "2022-08-15T09:38:21.0000000Z"
      expiry      = "2023-08-15T10:38:21.0000000Z"
    }
  }
  depends_on      = [data.azurerm_storage_account.storagaacct]
}

