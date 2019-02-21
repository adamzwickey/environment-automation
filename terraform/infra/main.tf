
resource "google_compute_subnetwork" "infrastructure" {
  name                     = "${var.env_name}-infrastructure-subnet"
  ip_cidr_range            = "${var.infrastructure_cidr}"
  network                  = "${var.network_name}"
  region                   = "${var.region}"
  private_ip_google_access = "${var.internetless}"
}

resource "google_compute_subnetwork" "pks" {
  name                     = "${var.env_name}-pks-subnet"
  ip_cidr_range            = "${var.pks_cidr}"
  network                  = "${var.network_name}"
  region                   = "${var.region}"
  private_ip_google_access = "${var.internetless}"
}

resource "google_compute_subnetwork" "pas" {
  name                     = "${var.env_name}-pas-subnet"
  ip_cidr_range            = "${var.pas_cidr}"
  network                  = "${var.network_name}"
  region                   = "${var.region}"
  private_ip_google_access = "${var.internetless}"
}

resource "google_compute_subnetwork" "services" {
  name                     = "${var.env_name}-service-subnet"
  ip_cidr_range            = "${var.services_cidr}"
  network                  = "${var.network_name}"
  region                   = "${var.region}"
  private_ip_google_access = "${var.internetless}"
}
