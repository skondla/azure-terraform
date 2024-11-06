resource "null_resource" "storage-container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "cc-chmrx2-arm-1a-tfstate" --account-name "confcomptfstateokweo8hp"
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
        container_name       = "cc-chmrx2-arm-1a-tfstate"
        key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 0.14"
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

resource "azurerm_resource_group_template_deployment" "ccvms" {
  count               = var.node_count
  name                = "${var.prefix}-${var.node_type}-${count.index + 1}"
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  template_content    = file("./templatecvm.json")
  tags = {
    application        = "cc-chmrx2"
    cxsast_node_prefix = var.prefix
    cxsast_node_type   = var.node_type
  }

  parameters_content = jsonencode({
    "vmLocation"                 = { value = var.vmLocation }
    "networkInterfaceName"       = { value = "${var.prefix}-${var.node_type}-network-interface-${count.index + 1}" }
    "subnetId"                   = { value = "${data.azurerm_subnet.app_subnet.id}" }
    "virtualMachineName"         = { value = "${var.prefix}-${var.node_type}-${count.index + 1}" }
    "virtualMachineComputerName" = { value = "${var.node_type}-${count.index + 1}" }
    "virtualMachineRG"           = { value = var.resource_group_name }
    "osImageName"                = { value = var.os_image_name }
    "osDiskType"                 = { value = "Premium_LRS" }
    "osType"                     = { value = var.os_type }
    "diskEncryptionSetId"        = { value = "${data.azurerm_disk_encryption_set.des.id}" }
    "virtualMachineSize"         = { value = var.size }
    "osDiskSize"                 = { value = var.disk_size }
    "nicDeleteOption"            = { value = "Detach" }
    "authenticationType"         = { value = var.os_type == "Linux" ? "sshPublicKey" : "password" }
    "adminUsername"              = { value = var.vm_admin_username }
    "adminPublicKey"             = { value = var.os_type == "Linux" ? var.adminPublicKey : var.appadminPassword}
    "securityType"               = { value = "DiskWithVMGuestState" }
    "secureBoot"                 = { value = true }
    "vTPM"                       = { value = true }
  })
}
