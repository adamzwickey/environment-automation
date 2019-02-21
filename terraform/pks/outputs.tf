output "pks_api_ip" {
  value = "${google_compute_address.pks-api-ip.address}"
}

output "pks_load_balancer_name" {
  value = "${module.pks-api.name}"
}

output "pks_master_node_service_account_key" {
  value = "${base64decode(google_service_account_key.pks_master_node_service_account_key.private_key)}"
}

output "pks_worker_node_service_account_key" {
  value = "${base64decode(google_service_account_key.pks_worker_node_service_account_key.private_key)}"
}
