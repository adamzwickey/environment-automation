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

variable "pks_cluster_name" {
  type = "string"
}

variable "create_gcs_buckets" {
  default = true
}

variable "buckets_location" {
  type = "string"
}

variable "dns_suffix" {
  type = "string"
}

variable "ssl_cert" {
  type        = "string"
  description = "The contents of an SSL certificate to be used by the LB, optional if `ssl_ca_cert` is provided"
  default     = ""
}

variable "ssl_private_key" {
  type        = "string"
  description = "The contents of an SSL private key to be used by the LB, optional if `ssl_ca_cert` is provided"
  default     = ""
}

variable "ssl_ca_cert" {
  type        = "string"
  description = "The contents of a CA public key to be used to sign the generated LB certificate, optional if `ssl_cert` is provided"
  default     = ""
}

variable "ssl_ca_private_key" {
  type        = "string"
  description = "the contents of a CA private key to be used to sign the generated LB certificate, optional if `ssl_cert` is provided"
  default     = ""
}
