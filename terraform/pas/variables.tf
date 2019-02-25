variable "project" {
  type = "string"
}

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

variable "buckets_location" {
  default = ""
}

variable "ssl_certificate" {
  type = "string"
}

variable "global_lb" {
  default = "1"
}

variable "zones" {
  type = "list"
}
