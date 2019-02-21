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
