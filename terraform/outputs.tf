output "iaas" {
  value = "gcp"
}

output "project" {
  value = "${var.project}"
}

output "region" {
  value = "${var.region}"
}

output "infra_network_name" {
  value = "${module.infra.infra_network_name}"
}

output "infra_subnet" {
  value = "${module.infra.infra_subnet}"
}

output "infra_ip_cidr_range" {
  value = "${module.infra.infra_ip_cidr_range}"
}

output "pks_network_name" {
  value = "${module.infra.pks_network_name}"
}

output "pks_subnet" {
  value = "${module.infra.pks_subnet}"
}

output "pks_ip_cidr_range" {
  value = "${module.infra.pks_ip_cidr_range}"
}

output "pas_network_name" {
  value = "${module.infra.pas_network_name}"
}

output "pas_subnet" {
  value = "${module.infra.pas_subnet}"
}

output "pas_ip_cidr_range" {
  value = "${module.infra.pas_ip_cidr_range}"
}

output "services_network_name" {
  value = "${module.infra.services_network_name}"
}

output "services_subnet" {
  value = "${module.infra.services_subnet}"
}

output "services_ip_cidr_range" {
  value = "${module.infra.services_ip_cidr_range}"
}
