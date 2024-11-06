#Create a Terraform configuration with a backend configuration block
resource "null_resource" "storage-container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "cvm-vmss-linux-tfstate" --account-name "confcomptfstateokweo8hp"
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
        container_name       = "cvm-vmss-linux-tfstate"
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

###VMSS - linux

resource "azurerm_linux_virtual_machine_scale_set" "cvm-ss-lnx" {
  name                = "cvm-vmss-lnx"
  resource_group_name  = "${var.vnet_resource_group}"
  location             = "${var.vmLocation}"
  sku                 = "Standard_DC2as_v5"
  instances            = var.node_count
  admin_username      = var.vm_admin_username
  custom_data          = "${data.template_cloudinit_config.config.rendered}"

  admin_ssh_key {
    username    = var.vm_admin_username
    public_key  = var.adminPublicKey  
  }

  os_disk {
    caching                          = "ReadWrite"
    storage_account_type             = "Standard_LRS"
    security_encryption_type         = "DiskWithVMGuestState"
    #secure_vm_disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id
    #disk_encryption_set_id    = data.azurerm_disk_encryption_set.des.id
  }

  #Data disk block - Lun 0
  data_disk {
    storage_account_type      = "Standard_LRS"
    caching                   = "ReadWrite"
    #security_encryption_type  = "DiskWithVMGuestState"
    #secure_vm_disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id
    disk_size_gb              = 32
    lun                       = 0
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-confidential-vm-focal"
    sku       = "20_04-lts-cvm"
    version   = "latest"
  }

  network_interface {
    name    = "cvm-vmss-lnx"
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

#Errors

/*
╷
│ Error: creating Linux Virtual Machine Scale Set: (Name "cvm-vmss-lnx" / Resource Group "futureai-conf-compute-mvp"): compute.VirtualMachineScaleSetsClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: Code="BadRequest" Message="Virtual Machines Scale Sets do not allow setting managedDisk.securityProfile.diskEncryptionSet."

│ Error: waiting for creation of Linux Virtual Machine Scale Set: (Name "cvm-vmss-lnx" / Resource Group "futureai-conf-compute-mvp"): Code="BadRequest" Message="Encryption Type ConfidentialVmEncryptedWithCustomerKey is not supported for server side encryption with customer managed key.  Target: '/subscriptions/45adad4f-3a50xxxxx-yyyyyy-zzzz/resourceGroups/futureai-conf-compute-mvp/providers/Microsoft.Compute/disks/cvm-vmss-lnx_cvm-vmss-lnx_0_OsDisk_1_d4cac81b5b9742cdbc85738b9240fef3'."
*/