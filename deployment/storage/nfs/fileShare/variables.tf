variable "prefix" {
  description = "The Prefix used for all resources in this example"
  default = "futureai"
}

variable "resource_group_name" {
  description = "(Required) The name of the existing resource group where the storage account resources will be placed."
  default     = "futureai-conf-compute-mvp"
  type        = string
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "West US"
}

variable "secondary_location" {
  description = "The Azure Region in which all resources in this example should be created."
  #default = "East US"
  default     = "Central US"
}

variable "resource_group_name_des" {
  type = string
  default = "sst-cxsast-mvp-cc"
}

variable "confidentialDiskEncryptionSetId" {
  type        = string
}
variable "vnet_resource_group" {
  type    = string
  default = "futureai-conf-compute-mvp"
}

variable "virtual_network_name" {
  type    = string
  default = "chkmrx-mvp-vnet1"
}

variable "vnet_cidr_block" {
  type    = string
}

variable "owner" {
  description = "Ower of deployment"
  type        = string
  default     = "skondla@me.com"
}

variable "cost_center_name" {
  description = "Cost Center Name"
  type        = string
  default     = "future.ai"
}

variable "cost_center_code" {
  description = "Cost Center Code"
  type        = number
  default     = 23745
}

variable "storage_account" {
  description = "Storage Account"
  type        = string
  default     = "futureaisafiles"
}

variable "nfsv3_enabled" {
  type    = bool
}

variable "enable_https_traffic_only" {
  type    = bool 
}

variable "min_tls_version" {
  type    = string
}

variable "large_file_share_enabled" {
  type    = bool
}

variable "infrastructure_encryption_enabled" {
  type    = bool
}

variable "is_hns_enabled" {
  type    = bool
}

variable "storage_containers" {
  default = [
      "test",
      "terraform",
      "vmshare"
  ]
}

variable "myshare_nfs" {
  type    = string
}

variable "myshare_smb" {
  type    = string
}
