data "google_compute_network" "pcf-network" {
  name = "${var.network_name}"
}
