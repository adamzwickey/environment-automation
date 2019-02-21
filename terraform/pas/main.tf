data "google_compute_network" "pcf-network" {
  name = "${var.network_name}"
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

//// Allow access to ssh-proxy [Optional]
resource "google_compute_firewall" "cf-ssh-proxy" {
  name       = "${var.env_name}-allow-ssh-proxy"
  depends_on = ["data.google_compute_network.pcf-network"]
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
  depends_on = ["data.google_compute_network.pcf-network"]
  network    = "${var.network_name}"

  allow {
    protocol = "tcp"
    ports    = ["1024-65535"]
  }

  target_tags = ["${var.env_name}-cf-tcp-lb"]
}
