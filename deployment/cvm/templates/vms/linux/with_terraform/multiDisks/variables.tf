variable "prefix" {
  type = string
  default = "ccvm-tfarm-chmrx"
}

variable "node_type" {
  type = string
  default = "linux"
}

variable "resource_group_name" {
  type = string
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

variable "location" {
  type    = string
  default = "westus"
}

variable "node_count" {
  type    = number
  default = 2
}

variable "application" {
  type    = string
  default = null
}

variable "owner" {
  type    = string
  default = null
}

variable "cost_center_name" {
  type    = string
  default = "future.ai"
}

variable "cost_center_code" {
  type    = number
  default = 23745
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
  default = "Standard"
}

variable "size" {
  type    = string
  default = "Standard_DC4as_v5"
  #default = null
}

variable "disk_encription_set" {
  type = string
  #default = ""
  default = "des-encrypt-set"
}

variable "os_type" {
  type = string
  default = ""
}

variable "os_image_name" {
  type = string
  default = ""
}

variable "key_vault_key_id" {
  type = string
  default = ""
  #default = "https://des-sast-keyvault-cc6.vault.azure.net/"
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