variable "location" {
  description = "(Optional) The location/region where the load balancer will be created. If not provided, will use the location of the resource group."
  default     = "westus"
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the existing resource group where the load balancer resources will be placed."
  default     = "futureai-conf-compute-mvp"
  type        = string
}

variable "prefix" {
  description = "(Required) Default prefix to use with your resource names."
  default     = "cxsast"
  type        = string
}

variable "remote_port" {
  description = "Protocols to be used for remote vm access. [protocol, backend_port].  Frontend port will be automatically generated starting at 50000 and in the output."
  default     = {}
  type        = map(list(string))
}

variable "lb_port" {
  description = "Protocols to be used for lb health probes and rules. [frontend_port, protocol, backend_port]"
  default     = {}
  type        = map(list(string))
}

variable "lb_probe_unhealthy_threshold" {
  description = "(Optional) Number of times the load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy. Default = 2."
  default     = 2
  type        = number
}

variable "lb_probe_interval" {
  description = "Interval in seconds the load balancer health probe rule does a check"
  default     = 5
  type        = number
}

variable "frontend_name" {
  description = "(Optional) Specifies the name of the frontend ip configuration."
  default     = "FrontendIP"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "(optional) Tags to use in addition to tags assigned to the resource group."

  default = {
    source = "terraform"
  }
}

variable "type" {
  type        = string
  description = "(Optional) Defined if the loadbalancer is private or public. Default private."
  default     = "public"
}

variable "subnet_id" {
  description = "(Optional) Frontend subnet id to use when in private mode"
  default     = "AppSubnet"
  type        = string
}

variable "private_ip_address" {
  description = "(Optional) Private ip address to assign to frontend. Use it with type = private"
  default     = ""
  type        = string
}

variable "allocation_method" {
  description = "(Required) Defines how an IP address is assigned. Options are Static or Dynamic."
  type        = string
  default     = "Static"
}

variable "frontend_subnet_id" {
  description = "(Optional) Frontend subnet id to use when in private mode"
  type        = string
  default     = ""
}

variable "frontend_private_ip_address" {
  description = "(Optional) Private ip address to assign to frontend. Use it with type = private"
  type        = string
  default     = ""
}

variable "frontend_private_ip_address_allocation" {
  description = "(Optional) Frontend ip allocation type (Static or Dynamic)"
  type        = string
  default     = "Dynamic"
}

variable "lb_sku" {
  description = "(Optional) The SKU of the Azure Load Balancer. Accepted values are Basic and Standard."
  type        = string
  default     = "Basic"
}

variable "lb_probe" {
  description = "(Optional) Protocols to be used for lb health probes. Format as [protocol, port, request_path]"
  type        = map(any)
  default     = {}
}

variable "pip_sku" {
  description = "(Optional) The SKU of the Azure Public IP. Accepted values are Basic and Standard."
  type        = string
  default     = "Basic"
}

variable "name" {
  description = "(Optional) Name of the load balancer. If it is set, the 'prefix' variable will be ignored."
  type        = string
  default     = ""
}

variable "pip_name" {
  description = "(Optional) Name of public ip. If it is set, the 'prefix' variable will be ignored."
  type        = string
  default     = ""
}