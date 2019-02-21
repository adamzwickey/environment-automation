output "infra_network_name" {
  value = "${google_compute_subnetwork.infrastructure.name}"
}

output "infra_subnet" {
  value = "${google_compute_subnetwork.infrastructure.self_link}"
}

output "infra_ip_cidr_range" {
  value = "${google_compute_subnetwork.infrastructure.ip_cidr_range}"
}
