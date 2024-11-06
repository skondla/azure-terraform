variable "prefix" {
  description = "The Prefix used for all resources in this example"
  default = "futureai"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "West US"
}

variable "resource_group_name" {
  description = "(Required) The name of the existing resource group where the application gateway resources will be placed."
  default     = "futureai-conf-compute-mvp"
  type        = string
}

variable "virtual_network" {
  description = "(Required) The name of the existing virtual network(vnet) where the application gateway resources will be placed."
  default     = "chkmrx-mvp-vnet1"
  type        = string
}

variable "vnet_address_prefix" {
  description = "(Required) The name of the existing virtual network(vnet) where the application gateway resources will be placed."
  default     = "172.21.39.0/24"
  type        = string
}