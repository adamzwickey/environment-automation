
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

// Allow ssh from public networks
resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.env_name}-allow-ssh"
  network = "${var.network_name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

// Allow http from public
resource "google_compute_firewall" "pcf-allow-http" {
  name    = "${var.env_name}-allow-http"
  network = "${var.network_name}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http", "router"]
}

// Allow https from public
resource "google_compute_firewall" "pcf-allow-https" {
  name    = "${var.env_name}-allow-https"
  network = "${var.network_name}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-https", "router"]
}

//// GO Router Health Checks
resource "google_compute_firewall" "pcf-allow-http-8080" {
  name    = "${var.env_name}-allow-http-8080"
  network = "${var.network_name}"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["router"]
}

//// Create Firewall Rule for allow-ert-all com between bosh deployed ert jobs
//// This will match the default OpsMan tag configured for the deployment
resource "google_compute_firewall" "allow-ert-all" {
  name       = "${var.env_name}-allow-ert-all"
  depends_on = ["google_compute_network.pcf-virt-net"]
  network    = "${var.network_name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  target_tags = ["${var.env_name}", "${var.env_name}-opsman", "nat-traverse"]
  source_tags = ["${var.env_name}", "${var.env_name}-opsman", "nat-traverse"]
}

//// Allow access to ssh-proxy [Optional]
resource "google_compute_firewall" "cf-ssh-proxy" {
  name       = "${var.env_name}-allow-ssh-proxy"
  depends_on = ["google_compute_network.pcf-virt-net"]
  network    = "${var.network_name}"

  allow {
    protocol = "tcp"
    ports    = ["2222"]
  }

  target_tags = ["${var.env_name}-ssh-proxy", "diego-brain"]
}

//// Allow access to Optional CF TCP router
resource "google_compute_firewall" "cf-tcp" {
  name       = "${var.env_name}-allow-cf-tcp"
  depends_on = ["google_compute_network.pcf-virt-net"]
  network    = "${var.network_name}"

  allow {
    protocol = "tcp"
    ports    = ["1024-65535"]
  }

  target_tags = ["${var.env_name}-cf-tcp-lb"]
}
