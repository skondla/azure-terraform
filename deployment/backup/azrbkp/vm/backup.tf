#Create a Terraform configuration with a backend configuration block
resource "null_resource" "container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "ccvm-azr-backup-vm-tfstate" --account-name "confcomptfstateokweo8hp"
    EOT
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.10"
    }
  }
    backend "azurerm" {
        resource_group_name  = "conf-compute-tfstate"
        storage_account_name = "confcomptfstateokweo8hp"
        container_name       = "ccvm-azr-backup-vm-tfstate"
        key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

# Azure load balancer module
data "azurerm_resource_group" "azrbackup" {
  name = var.resource_group_name
  #location = var.location
}

data "azurerm_virtual_machine" "cvm-linux" {
  name                = "cvm-linux-1"
  resource_group_name = var.resource_group_name
}

output "virtual_machine_id" {
  value = data.azurerm_virtual_machine.cvm-linux.id
}

resource "azurerm_recovery_services_vault" "azrrecoveryvault" {
  name                = "${var.prefix}-recovery-vault"
  location            = data.azurerm_resource_group.azrbackup.location
  resource_group_name = data.azurerm_resource_group.azrbackup.name
  sku                 = "Standard"
}

resource "azurerm_backup_policy_vm" "azrbackupvmpolicy" {
  name                = "vm-recovery-vault-policy"
  resource_group_name = data.azurerm_resource_group.azrbackup.name
  recovery_vault_name = azurerm_recovery_services_vault.azrrecoveryvault.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "07:00"
  }

  retention_daily {
    count = 8
  }

  retention_weekly {
    count    = 7
    weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"]
  }

  retention_monthly {
    count    = 3
    weekdays = ["Sunday", "Wednesday"]
    weeks    = ["First", "Last"]
  }

  retention_yearly {
    count    = 36
    weekdays = ["Sunday"]
    weeks    = ["Last"]
    months   = ["January"]
  }
}


resource "azurerm_backup_protected_vm" "cvm-linux" {
  resource_group_name = data.azurerm_resource_group.azrbackup.name
  recovery_vault_name = azurerm_recovery_services_vault.azrrecoveryvault.name
  source_vm_id        = data.azurerm_virtual_machine.cvm-linux.id
  #source_vm_id        = "cvm-linux-1"
  backup_policy_id    = azurerm_backup_policy_vm.azrbackupvmpolicy.id
  depends_on = ["null_resource.delay"]
}


/*
resource "azurerm_site_recovery_fabric" "recoveryfabric" {
  name                = "primary-fabric"
  resource_group_name = data.azurerm_resource_group.azrbackup.name
  recovery_vault_name = azurerm_recovery_services_vault.azrrecoveryvault.name
  location            = data.azurerm_resource_group.azrbackup.location
}
*/

# This resource is defined to fix the timeout problem in the creation of 'azurerm_recovery_services_protected_vm.*' resources
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 180"
  }

  depends_on = [
    data.azurerm_virtual_machine.cvm-linux
  ]
}
