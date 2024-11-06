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

variable "appgw_subnet_id" {
  description = "(Optional) Firewall subnet id to use when in private mode"
  default     = "AppGatewaySubnet"
  type        = string
}

variable "endpoint_subnet_id" {
  description = "(Optional) Firewall subnet id to use when in private mode"
  default     = "AppEndPointSubnet"
  type        = string
}

variable "cloudconfig_file" {
  description = "The location of the cloud init configuration file."
  default = "cloudconfig.yaml"
}

variable "cookie_based_affinity" {
  description = "cookie based affinity can direct subsequent traffic from a user session to the same server for processing"
  default = "Disabled" #Possible Values: Enabled, Disabled
}

variable "waf_enabled" {
  description = "Set to true to enable WAF on Application Gateway."
  type        = bool
  default     = true
}

variable "waf_configuration" {
  description = "Configuration block for WAF."
  type = object({
    firewall_mode            = string
    rule_set_type            = string
    rule_set_version         = string
    file_upload_limit_mb     = number
    max_request_body_size_kb = number
  })
  default = null
}

variable "sslExportPasswd" {
  description = "The password for SSL certificate export"
  type        = string
}
