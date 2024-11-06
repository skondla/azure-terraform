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


variable "vnet_resource_group" {
  type    = string
  default = "futureai-conf-compute-mvp"
}

variable "virtual_network_name" {
  type    = string
  default = "chkmrx-mvp-vnet1"
}

variable "app_subnet_name" {
  type    = string
  default = "AppSubnet"
}

variable "db_subnet_name" {
  type    = string
  default = "DBSubnet"
}

variable "bastion_subnet_name" {
  type    = string
  default = "BastionSubnet"
}

variable "pe_subnet_name" {
  type    = string
  default = "AppEndPointSubnet"
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
  default     = "futureaisa"
}

