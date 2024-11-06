variable "prefix" {
  type = string
}

variable "node_type" {
  type = string
}

variable "resource_group_name" {
  type = string
  default = "futureai-conf-compute-mvp"
}

variable "resource_group_name_des" {
  type = string
  default = "sst-cxsast-mvp-cc"
}

variable "vnet_resource_group" {
  type    = string
  default = "futureai-conf-compute-mvp"
}

variable "virtual_network_name" {
  type    = string
  default = "chkmrx-mvp-vnet1"
}

variable "subnet_name" {
  type    = string
  default = "AppSubnet"
}

variable "vm_admin_username" {
  type = string
  default = "adminuser"
}

variable "vmLocation" {
  type    = string
  default = "West US"
}

variable "node_count" {
  type    = number
  default = 1
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "external_ip_names" {
  type    = list(string)
  default = []
}

variable "external_ip_type" {
  type    = string
  default = "Basic"
}

variable "size" {
  type    = string
  default = "Standard_DC2as_v5"
}

variable "os_type" {
  type = string
  default = ""
}

variable "os_image_name" {
  type = string
  default = "Ubuntu 20.04 LTS Gen 2"
}

variable "disk_size" {
  type    = number
  default = 30
}

variable "storage_account_type" {
  type    = string
  default = "Standard_LRS"
}

variable "label_secondaries" {
  type    = bool
  default = false
}

variable "network_security_group" {
  type    = any # Resouce passthrough is object of undetermined types so any is required
  default = null
}

variable "adminPublicKey" {
  type    = string
}

variable "appadminPassword" {
  type    = string
}

variable "authType" {
  type = string
  default = ""
}

/*
variable "confidentialDiskEncryptionSetId" {
  type    = string
  default = "/subscriptions/45adad4f-3a50xxxxx-yyyyyy-zzzz/resourceGroups/SST-CXSAST-MVP-CC/providers/Microsoft.Compute/diskEncryptionSets/CheckMarx-HSM-Disk-Encryption-Set-Prod"
}
*/
