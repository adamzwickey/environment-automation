output "pks_master_node_service_account_key" {
  value = "${base64decode(google_service_account_key.pks_master_node_service_account_key.private_key)}"
}

output "pks_worker_node_service_account_key" {
  value = "${base64decode(google_service_account_key.pks_worker_node_service_account_key.private_key)}"
}
