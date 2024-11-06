#Create a Terraform configuration with a backend configuration block
resource "null_resource" "storage-container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "cc-cvm-ss-tfstate" --account-name "confcomptfstateokweo8hp"
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
        container_name       = "cc-cvm-ss-tfstate"
        key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

terraform {
  required_version = ">=1.0"
}

data "azurerm_disk_encryption_set" "des" {
  #name                = "${var.confidentialDiskEncryptionSetId}"
  name                = "CheckMarx-HSM-Disk-Encryption-Set-Prod"
  resource_group_name = var.resource_group_name_des
}

data "azurerm_subnet" "app_subnet" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${var.virtual_network_name}"
  resource_group_name  = "${var.vnet_resource_group}"
}

output os_image_name {
  value = "${var.os_image_name}"
}

#Create cloud-init cloudconfig

data "template_file" "cloudconfig" {
  template = "${file("${var.cloudconfig_file}")}"
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudconfig.rendered}"
  }
}


###VMSS - Windows
resource "azurerm_windows_virtual_machine_scale_set" "cvm-ss-win" {
  name                 = "${var.prefix}-win"
  resource_group_name  = "${var.vnet_resource_group}"
  location             = "${var.vmLocation}"
  

  # Available skus for Confidential VMSS can be found at: https://docs.microsoft.com/azure/confidential-computing/confidential-vm-overview
  sku                  = "Standard_DC2as_v5"
  instances            = var.node_count
  admin_username       = var.vm_admin_username
  admin_password       = var.appadminPassword
  computer_name_prefix = "${var.prefix}-win"
  custom_data          = "${data.template_cloudinit_config.config.rendered}"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "windows-cvm"
    sku       = "2022-datacenter-cvm"
    version   = "latest"
  }

  os_disk {
    storage_account_type     = "Premium_LRS"
    caching                  = "ReadWrite"
    security_encryption_type = "VMGuestStateOnly"
    #disk_encryption_set_id    = data.azurerm_disk_encryption_set.des.id
  }

  #Data disk block - Lun 0
  data_disk {
    storage_account_type      = "Premium_LRS"
    caching                   = "ReadWrite"
    #disk_encryption_set_id    = data.azurerm_disk_encryption_set.des.id
    disk_size_gb              = 32
    #lun                       = "LUN-${instances.index + 1}"
    lun                       = 0
  }

   #Data disk block - Lun 1
   /*
  data_disk {
    storage_account_type      = "Premium_LRS"
    caching                   = "ReadWrite"
    #disk_encryption_set_id    = data.azurerm_disk_encryption_set.des.id
    disk_size_gb              = 32
    lun                       = 1
  }
  */

/*
│ Error: waiting for creation of Windows Virtual Machine Scale Set: (Name "cc-win" / Resource Group "futureai-conf-compute-mvp"): Code="BadRequest" Message="Encryption Type ConfidentialVmEncryptedWithCustomerKey is not supported for server side encryption with customer managed key.  Target: '/subscriptions/45adad4f-3a50xxxxx-yyyyyy-zzzz/resourceGroups/futureai-conf-compute-mvp/providers/Microsoft.Compute/disks/cc-win_cc-win_0_OsDisk_1_e6b48e69db124e50b2c02a2aa5f397ca'."
│ 
│   with azurerm_windows_virtual_machine_scale_set.cvm-ss-win,
│   on cvm-ss.tf line 50, in resource "azurerm_windows_virtual_machine_scale_set" "cvm-ss-win":
│   50: resource "azurerm_windows_virtual_machine_scale_set" "cvm-ss-win" {

 Error: waiting for creation of Windows Virtual Machine Scale Set: (Name "cc-win" / Resource Group "futureai-conf-compute-mvp"): Code="BadRequest" Message="Encryption Type ConfidentialVmEncryptedWithCustomerKey is not supported for server side encryption with customer managed key.  Target: '/subscriptions/45adad4f-3a50xxxxx-yyyyyy-zzzz/resourceGroups/futureai-conf-compute-mvp/providers/Microsoft.Compute/disks/cc-win_cc-win_0_disk2_afcd3790f18d416aa8b13435085fc74d'."
│ 
│   with azurerm_windows_virtual_machine_scale_set.cvm-ss-win,
│   on cvm-ss.tf line 50, in resource "azurerm_windows_virtual_machine_scale_set" "cvm-ss-win":
│   50: resource "azurerm_windows_virtual_machine_scale_set" "cvm-ss-win" {
│ 
*/

  network_interface {
    name    = "cvm-ss-win"
    primary = true
    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = "${data.azurerm_subnet.app_subnet.id}"
    }
  }

  vtpm_enabled        = true
  secure_boot_enabled = true
}

// Disk Encryption Extension
/*
resource "azurerm_virtual_machine_extension" "cvm-ss-lnx" {
  name                       = "AzureDiskEncryptionForLinux"
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryptionForLinux"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = false
  virtual_machine_id         = azurerm_linux_virtual_machine_scale_set.cvm-ss-lnx.id

  settings = jsonencode({
    "EncryptionOperation"    = "EnableEncryption"
    "KeyEncryptionAlgorithm" = "RSA-OAEP"
    "KeyVaultURL"            = azurerm_key_vault.cvm-ss-lnx.vault_uri
    "KeyVaultResourceId"     = azurerm_key_vault.cvm-ss-lnx.id
    "KeyEncryptionKeyURL"    = azurerm_key_vault_key.cvm-ss-lnx.id
    "KekVaultResourceId"     = azurerm_key_vault.cvm-ss-lnx.id
    "VolumeType"             = "All"
  })
}
*/