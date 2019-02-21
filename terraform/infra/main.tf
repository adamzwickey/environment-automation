
resource "google_compute_subnetwork" "infrastructure" {
  name                     = "${var.env_name}-infrastructure-subnet"
  ip_cidr_range            = "${var.infrastructure_cidr}"
  network                  = "${var.network_name}"
  region                   = "${var.region}"
  private_ip_google_access = "${var.internetless}"
}
