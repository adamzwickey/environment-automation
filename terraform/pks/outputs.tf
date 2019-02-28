output "pks_load_balancer_name" {
  value = "${module.pks-api.name}"
}

output "pks_cluster_load_balancer_name" {
  value = "${module.pks-cluster-1.name}"
}

output "pks_master_node_service_account_key" {
  value = "${base64decode(google_service_account_key.pks_master_node_service_account_key.private_key)}"
}

output "pks_worker_node_service_account_key" {
  value = "${base64decode(google_service_account_key.pks_worker_node_service_account_key.private_key)}"
}

output "pks_api_load_balancer_name" {
  value = "${module.pks-api.name}"
}

output "pks_cluster1_load_balancer_name" {
  value = "${module.pks-cluster-1.name}"
}
