variable "env_name" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "project" {
  type = "string"
}

variable "network_name" {
  type        = "string"
  description = "GCP VPC Network"
  default     = "bosh-bootstrap"
}

variable "enable_gcr" {
  default = false
}

variable "dns_zone_dns_name" {
  type = "string"
}

variable "dns_zone_name" {
  type = "string"
}
