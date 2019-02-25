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

variable "create_gcs_buckets" {
  default = true
}

variable "buckets_location" {}

variable "ssl_certificate" {
  type = "string"
}
