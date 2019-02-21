variable "env_name" {
  type = "string"
}

variable "region" {
  type = "string"
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
