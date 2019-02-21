provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
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
  pks_cidr                             = "${var.pks_cidr}"
  pas_cidr                             = "${var.pas_cidr}"
  services_cidr                        = "${var.services_cidr}"
  internetless                         = "${var.internetless}"
  dns_zone_dns_name                    = "${var.dns_zone_dns_name}"
  dns_zone_name                        = "${var.dns_zone_name}"
}
