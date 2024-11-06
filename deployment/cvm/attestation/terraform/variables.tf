variable "resource_group_name" {
  type = string
  default = "futureai-conf-compute-mvp"
}

variable "resource_group_location" {
  default = "westus"
}

variable "policy_file" {
  default = "certs/<policy_file>"
}

variable "attestation_provider_name" {
  default = "attestationprovider01"
}
