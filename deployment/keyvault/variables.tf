variable "appadminUsername" {
  description = "The username for local admin on windows vm"
  type        = string
  default = "adminuser"
}

variable "appadminPassword" {
  description = "The password for local admin on windows vm"
  type        = string
}
variable "dbadminUsername" {
  description = "The username for local admin on windows vm"
  type        = string
  default = "dbadmin"
}

variable "dbadminPassword" {
  description = "The password for local admin on windows vm"
  type        = string
}

variable "sslExportPasswd" {
  description = "The password for SSL certificate export"
  type        = string
}
variable "prefix" {
  description = "The Prefix used for all resources in this example"
  default = "futureaiconfcomp"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "West US"
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
