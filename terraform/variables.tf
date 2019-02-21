variable "project" {
  type = "string"
}

variable "service_account_key" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "env_name" {
  type = "string"
  description = "Default env name.  Often used as a prefix"
  default     = "pcf"
}

variable "network_name" {
  type        = "string"
  description = "GCP VPC Network"
  default     = "bosh-bootstrap"
}

variable "infrastructure_cidr" {
  type        = "string"
  description = "CIDR for Infra network"
  default     = "10.0.1.0/26"
}

variable "internetless" {
  description = "When set to true, all traffic going outside the 10.* network is denied."
  default     = false
}
