# ------------------------------------
# Public: allow ingress from anywhere
# ------------------------------------
resource "google_compute_firewall" "public_allow_all_inbound" {
  name = "${var.prefix}-firewall-public-allow-ingress"

  # A reference to the vpc network.
  network = var.network

  target_tags   = [local.public]
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  priority = "1000"

  allow {
    protocol = "all"
  }

}
