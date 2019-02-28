output "iaas" {
  value = "gcp"
}

output "project" {
  value = "${var.project}"
}

output "region" {
  value = "${var.region}"
}

output "env_name" {
  value = "${var.env_name}"
}

output "network_name" {
  value = "${var.network_name}"
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

output "ops_manager_ip" {
  value = "${module.infra.ops_manager_ip}"
}

output "pks_lb_backend_name" {
  value = "${module.pks.pks_load_balancer_name}"
}

output "pks_cluster_lb_backend_name" {
  value = "${module.pks.pks_cluster_load_balancer_name}"
}

output "pks_master_node_service_account_key" {
  value = "${module.pks.pks_worker_node_service_account_key}"
}

output "pks_worker_node_service_account_key" {
  value = "${module.pks.pks_worker_node_service_account_key}"
}

output "bosh_load_balancer_name" {
  value = "${module.infra.bosh_load_balancer_name}"
}

output "bosh_load_balancer_address" {
  value = "${module.infra.bosh_load_balancer_address}"
}

output "pks_api_load_balancer_name" {
  value = "${module.pks.pks_api_load_balancer_name}"
}

output "pks_cluster1_load_balancer_name" {
  value = "${module.pks.pks_cluster1_load_balancer_name}"
}

output "buildpacks_bucket" {
  value = "${module.pas.buildpacks_bucket}"
}

output "droplets_bucket" {
  value = "${module.pas.droplets_bucket}"
}

output "packages_bucket" {
  value = "${module.pas.packages_bucket}"
}

output "resources_bucket" {
  value = "${module.pas.resources_bucket}"
}
