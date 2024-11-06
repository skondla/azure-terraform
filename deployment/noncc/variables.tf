variable "adminUsername" {
  description = "The username for local admin on windows vm"
  default = "adminuser"
}

variable "adminPassword" {
  description = "The password for local admin on windows vm"
  type        = string
}
