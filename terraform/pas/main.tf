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
    ports    = ["8080","8002"]
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

resource "google_storage_bucket" "buildpacks" {
  name          = "${var.project}-${var.env_name}-buildpacks"
  location      = "${var.buckets_location}"
  force_destroy = false
  count         = "${var.create_gcs_buckets ? 1 : 0}"
}

resource "google_storage_bucket" "droplets" {
  name          = "${var.project}-${var.env_name}-droplets"
  location      = "${var.buckets_location}"
  force_destroy = false
  count         = "${var.create_gcs_buckets ? 1 : 0}"
}

resource "google_storage_bucket" "packages" {
  name          = "${var.project}-${var.env_name}-packages"
  location      = "${var.buckets_location}"
  force_destroy = false
  count         = "${var.create_gcs_buckets ? 1 : 0}"
}

resource "google_storage_bucket" "resources" {
  name          = "${var.project}-${var.env_name}-resources"
  location      = "${var.buckets_location}"
  force_destroy = false
  count         = "${var.create_gcs_buckets ? 1 : 0}"
}

module "ssh-lb" {
  source = "../common/load_balancer"

  env_name = "${var.env_name}"
  name     = "ssh"

  global  = false
  count   = 1
  network = "${var.network_name}"

  ports                 = ["2222"]
  forwarding_rule_ports = ["2222"]
  lb_name               = "${var.env_name}-cf-ssh"

  health_check = false
}

module "gorouter" {
  source = "../common/load_balancer"

  env_name = "${var.env_name}"
  name     = "gorouter"

  global          = "${var.global_lb}"
  count           = "${var.global_lb > 0 ? 0 : 1}"
  network         = "${var.network_name}"
  zones           = "${var.zones}"
  ssl_certificate = "${var.ssl_certificate}"

  ports = ["80", "443"]

  lb_name               = "${var.env_name}-${var.global_lb > 0 ? "httpslb" : "tcplb"}"
  forwarding_rule_ports = ["80", "443"]

  health_check                     = true
  health_check_port                = "8080"
  health_check_interval            = 5
  health_check_timeout             = 3
  health_check_healthy_threshold   = 1
  health_check_unhealthy_threshold = 3
}

module "mesh" {
  source = "../common/load_balancer"

  env_name = "${var.env_name}"
  name     = "mesh"

  global          = false
  count           = "${var.mesh_lb > 0 ? 0 : 1}"
  network         = "${var.network_name}"
  zones           = "${var.zones}"
  ssl_certificate = "${var.ssl_certificate}"

  ports = ["80", "8002", "443"]

  lb_name               = "${var.env_name}-mesh"
  forwarding_rule_ports = ["80", "8002", "443"]

  health_check                     = true
  health_check_port                = "8002"
  health_check_interval            = 5
  health_check_timeout             = 3
  health_check_healthy_threshold   = 1
  health_check_unhealthy_threshold = 3
}

module "websocket" {
  source = "../common/load_balancer"

  env_name = "${var.env_name}"
  name     = "websocket"

  global  = false
  network = "${var.network_name}"
  count   = "${var.global_lb}"

  ports                 = ["80", "443"]
  lb_name               = "${var.env_name}-cf-ws"
  forwarding_rule_ports = ["80", "443"]

  health_check                     = true
  health_check_port                = "8080"
  health_check_interval            = 5
  health_check_timeout             = 3
  health_check_healthy_threshold   = 1
  health_check_unhealthy_threshold = 3
}

module "tcprouter" {
  source = "../common/load_balancer"

  env_name = "${var.env_name}"
  name     = "tcprouter"

  global  = false
  network = "${var.network_name}"
  count   = 1

  ports                 = ["1024-65535"]
  lb_name               = "${var.env_name}-cf-tcp"
  forwarding_rule_ports = ["1024-1123"]

  health_check                     = true
  health_check_port                = "80"
  health_check_interval            = 15
  health_check_timeout             = 5
  health_check_healthy_threshold   = 1
  health_check_unhealthy_threshold = 3
}

resource "google_dns_record_set" "wildcard-sys-dns" {
  name = "*.run.${var.dns_zone_dns_name}."
  type = "A"
  ttl  = 300

  managed_zone = "${var.dns_zone_name}"

  rrdatas = ["${module.gorouter.global_address}"]
}

resource "google_dns_record_set" "doppler-sys-dns" {
  name = "doppler.run.${var.dns_zone_dns_name}."
  type = "A"
  ttl  = 300

  managed_zone = "${var.dns_zone_name}"

  rrdatas = ["${module.websocket.address}"]
}

resource "google_dns_record_set" "loggregator-sys-dns" {
  name = "loggregator.run.${var.dns_zone_dns_name}."
  type = "A"
  ttl  = 300

  managed_zone = "${var.dns_zone_name}"

  rrdatas = ["${module.websocket.address}"]
}

resource "google_dns_record_set" "wildcard-apps-dns" {
  name = "*.apps.${var.dns_zone_dns_name}."
  type = "A"
  ttl  = 300

  managed_zone = "${var.dns_zone_name}"

  rrdatas = ["${module.gorouter.global_address}"]
}

resource "google_dns_record_set" "app-ssh-dns" {
  name = "ssh.run.${var.dns_zone_dns_name}."
  type = "A"
  ttl  = 300

  managed_zone = "${var.dns_zone_name}"

  rrdatas = ["${module.ssh-lb.address}"]
}

resource "google_dns_record_set" "tcp-dns" {
  name = "tcp.${var.dns_zone_dns_name}."
  type = "A"
  ttl  = 300

  managed_zone = "${var.dns_zone_name}"

  rrdatas = ["${module.tcprouter.address}"]
}

resource "google_dns_record_set" "wildcard-mesh-dns" {
  name = "*.mesh.apps.${var.dns_zone_dns_name}."
  type = "A"
  ttl  = 300

  managed_zone = "${var.dns_zone_name}"

  rrdatas = ["${module.mesh.address}"]
}
