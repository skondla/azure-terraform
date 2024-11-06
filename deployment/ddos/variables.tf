variable "resource_group_name" {
  description = "(Required) The name of the existing resource group where the Azure Firewall resources will be placed."
  default     = "futureai-conf-compute-mvp"
  type        = string
}

variable "location" {
  description = "(Optional) The location/region where the Azure Firewall will be created. If not provided, will use the location of the resource group."
  default     = "westus"
  type        = string
}

variable "virtual_network_name" {
  type    = string
  default = "chkmrx-mvp-vnet1"
}

variable "prefix" {
  description = "(Required) Default prefix to use with your resource names."
  default     = "cxsast"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "(optional) Tags to use in addition to tags assigned to the resource group."

  default = {
    source = "terraform"
  }
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


variable "environment" {
  description = "CC-"
  type        = number
  default     = 23745
}

variable "storage_account" {
  description = "Storage Account"
  type        = string
  default     = "futureaisa"
}