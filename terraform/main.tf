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

module "pas_certs" {
  source = "common/certs"

  subdomains    = ["*.apps", "*.run", "*.login.sys", "*.uaa.sys", "harbor", "pks", "*.pks"]
  env_name      = "${var.env_name}"
  dns_suffix    = "${var.dns_suffix}"
  resource_name = "pas-lbcert"

  ssl_cert           = "${var.ssl_cert}"
  ssl_private_key    = "${var.ssl_private_key}"
  ssl_ca_cert        = "${var.ssl_ca_cert}"
  ssl_ca_private_key = "${var.ssl_ca_private_key}"
}

 module "pas" {
  source = "pas"

  project                              = "${var.project}"
  network_name                         = "${var.network_name}"
  env_name                             = "${var.env_name}"
  region                               = "${var.region}"
  ssl_certificate                      = "${module.pas_certs.ssl_certificate}"
  dns_zone_dns_name                    = "${var.zones}"
}

module "pks" {
  source = "pks"

  project                              = "${var.project}"
  network_name                         = "${var.network_name}"
  env_name                             = "${var.env_name}"
  region                               = "${var.region}"
  dns_zone_dns_name                    = "${var.dns_zone_dns_name}"
  dns_zone_name                        = "${var.dns_zone_name}"
  pks_cluster_name                     = "${var.pks_cluster_name}"
}
