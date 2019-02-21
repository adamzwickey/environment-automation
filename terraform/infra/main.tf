data "google_compute_network" "pcf-network" {
  name = "${var.network_name}"
}

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

//// Create Firewall Rule for allow-pcf-all com between bosh deployed pcf jobs
//// This will match the default OpsMan tag configured for the deployment
resource "google_compute_firewall" "allow-pcf-all" {
  name       = "${var.env_name}-allow-pcf-all"
  depends_on = ["data.google_compute_network.pcf-network"]
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

  # Allow HTTP/S access to Ops Manager from the outside world
  resource "google_compute_firewall" "ops-manager-external" {
    name        = "${var.env_name}-ops-manager-external"
    network     = "${var.pcf_network_name}"
    target_tags = ["${var.env_name}-ops-manager-external"]

    allow {
      protocol = "icmp"
    }

    allow {
      protocol = "tcp"
      ports    = ["22", "80", "443"]
    }
  }


  target_tags = ["${var.env_name}-opsman"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "ops-manager-ip" {
  name = "${var.env_name}-ops-manager-ip"
}

resource "google_dns_record_set" "ops-manager-dns" {
  name = "opsman.${var.dns_zone_dns_name}."
  type = "A"
  ttl  = 300

  managed_zone = "${var.dns_zone_name}"

  rrdatas = ["${google_compute_address.ops-manager-ip.address}"]
}
