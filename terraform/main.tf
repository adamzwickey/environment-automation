provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  credentials = "${var.service_account_key}"
  version = ">= 1.7.0"
}

terraform {
  required_version = "< 0.12.0"
}

module "infra" {
  source = "infra"

  network_name                         = "${var.network_name}"
  env_name                             = "${var.env_name}"
  region                               = "${var.region}"
  infrastructure_cidr                  = "${var.infrastructure_cidr}"
  internetless                         = "${var.internetless}"
}
