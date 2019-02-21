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
