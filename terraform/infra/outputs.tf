output "env_name" {
  value = "${var.env_name}"
}

output "infra_network_name" {
  value = "${google_compute_subnetwork.infrastructure.name}"
}

output "infra_subnet" {
  value = "${google_compute_subnetwork.infrastructure.self_link}"
}

output "infra_ip_cidr_range" {
  value = "${google_compute_subnetwork.infrastructure.ip_cidr_range}"
}

output "pks_network_name" {
  value = "${google_compute_subnetwork.pks.name}"
}

output "pks_subnet" {
  value = "${google_compute_subnetwork.pks.self_link}"
}

output "pks_ip_cidr_range" {
  value = "${google_compute_subnetwork.pks.ip_cidr_range}"
}

output "pas_network_name" {
  value = "${google_compute_subnetwork.pas.name}"
}

output "pas_subnet" {
  value = "${google_compute_subnetwork.pas.self_link}"
}

output "pas_ip_cidr_range" {
  value = "${google_compute_subnetwork.pas.ip_cidr_range}"
}

output "services_network_name" {
  value = "${google_compute_subnetwork.services.name}"
}

output "services_subnet" {
  value = "${google_compute_subnetwork.services.self_link}"
}

output "services_ip_cidr_range" {
  value = "${google_compute_subnetwork.services.ip_cidr_range}"
}

output "ops_manager_ip" {
  value = "${google_compute_address.ops-manager-ip.address}"
}

output "bosh_load_balancer_name" {
  value = "${module.bosh-lb.name}"
}

output "bosh_load_balancer_address" {
  value = "${module.bosh-lb.address}"
}
