data "google_compute_network" "pcf-network" {
  name = "${var.network_name}"
}

// Allow access to master nodes
resource "google_compute_firewall" "pks-master" {
  name    = "${var.env_name}-pks-master"
  network = "${var.network_name}"

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  target_tags = ["master"]
}

module "pks-api" {
  source   = "../common/load_balancer"
  env_name = "${var.env_name}"
  name     = "pks-api"

  global  = false
  count   = 1
  network = "${var.network_name}"

  ports                 = ["9021", "8443"]
  lb_name               = "${var.env_name}-pks-api"
  forwarding_rule_ports = ["9021", "8443"]
  health_check          = false
}

resource "google_dns_record_set" "pks-api-dns" {
  name = "pks.${var.dns_zone_dns_name}."
  type = "A"
  ttl  = 300

  managed_zone = "${var.dns_zone_name}"
  rrdatas = ["${module.pks-api.address}"]
}

module "pks-cluster-1" {
  source   = "../common/load_balancer"
  env_name = "${var.env_name}"
  name     = "pks-cluster-1"

  global  = false
  count   = 1
  network = "${var.network_name}"

  ports                 = ["9021", "8443"]
  lb_name               = "${var.env_name}-pks-cluster-1"
  forwarding_rule_ports = ["8443"]
  health_check          = false
}

resource "google_dns_record_set" "pks-cluster-dns" {
  name = "${var.pks_cluster_name}.pks.${var.dns_zone_dns_name}."
  type = "A"
  ttl  = 300

  managed_zone = "${var.dns_zone_name}"
  rrdatas = ["${module.pks-cluster-1.address}"]
}

resource "google_service_account" "pks_master_node_service_account" {
  account_id   = "${var.env_name}-pks-master"
  display_name = "${var.env_name} PKS Service Account"
}

resource "google_service_account_key" "pks_master_node_service_account_key" {
  service_account_id = "${google_service_account.pks_master_node_service_account.id}"
}

resource "google_service_account" "pks_worker_node_service_account" {
  account_id   = "${var.env_name}-pks-worker"
  display_name = "${var.env_name} PKS Service Account"
}

resource "google_service_account_key" "pks_worker_node_service_account_key" {
  service_account_id = "${google_service_account.pks_worker_node_service_account.id}"
}

resource "google_project_iam_member" "pks_master_node_compute_instance_admin" {
  project = "${var.project}"
  role    = "roles/compute.instanceAdmin"
  member  = "serviceAccount:${google_service_account.pks_master_node_service_account.email}"
}

resource "google_project_iam_member" "pks_master_node_compute_network_admin" {
  project = "${var.project}"
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.pks_master_node_service_account.email}"
}

resource "google_project_iam_member" "pks_master_node_compute_storage_admin" {
  project = "${var.project}"
  role    = "roles/compute.storageAdmin"
  member  = "serviceAccount:${google_service_account.pks_master_node_service_account.email}"
}

resource "google_project_iam_member" "pks_master_node_compute_security_admin" {
  project = "${var.project}"
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:${google_service_account.pks_master_node_service_account.email}"
}

resource "google_project_iam_member" "pks_master_node_iam_service_account_actor" {
  project = "${var.project}"
  role    = "roles/iam.serviceAccountActor"
  member  = "serviceAccount:${google_service_account.pks_master_node_service_account.email}"
}

resource "google_project_iam_member" "pks_worker_node_compute_viewer" {
  project = "${var.project}"
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.pks_worker_node_service_account.email}"
}

resource "google_project_iam_member" "pks_worker_node_storage_object_viewer" {
  count   = "${var.enable_gcr ? 1 : 0}"
  project = "${var.project}"
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.pks_worker_node_service_account.email}"
}
