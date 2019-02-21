variable "project" {
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

variable "pks_cidr" {
  type        = "string"
  description = "CIDR for PKS network"
  default     = "10.0.2.0/24"
}

variable "pas_cidr" {
  type        = "string"
  description = "CIDR for PAS network"
  default     = "10.0.3.0/24"
}

variable "services_cidr" {
  type        = "string"
  description = "CIDR for Services network"
  default     = "10.0.4.0/24"
}

variable "internetless" {
  description = "When set to true, all traffic going outside the 10.* network is denied."
  default     = false
}

variable "dns_zone_dns_name" {
  type = "string"
}

variable "dns_zone_name" {
  type = "string"
}

variable "enable_gcr" {
  default = false
}
