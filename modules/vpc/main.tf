# -----------------
# Network resources
# -----------------

resource "google_compute_network" "vpc" {
  name = "${var.prefix}-vpc"

  # When set to true, the network is created in "auto subnet mode" and it will
  # create a subnet for each region automatically across the 10.128.0.0/9
  # address range.
  # When set to false, the network is created in "custom subnet mode" so the
  # user can explicitly connect subnetwork resources.
  auto_create_subnetworks = "false"

  # If set to REGIONAL, network's cloud routers will only advertise routes
  # with subnetworks of this network in the same region as the router.
  routing_mode = "REGIONAL"

}

# Cloud Router works with both legacy networks and Virtual Private Cloud (VPC) networks.
#
# Cloud Router isn't a physical device that might cause a bottleneck.
# It can't be used by itself. But, it is required or recommended in the following cases:
#   - Required for Cloud NAT
#   - Required for Cloud Interconnect and HA VPN
#   - A recommended configuration option for Classic VPN
#
# More info: https://cloud.google.com/router/docs/concepts/overview
resource "google_compute_router" "vpc_router" {
  name = "${var.prefix}-router"

  # A reference to the vpc network.
  network = google_compute_network.vpc.self_link

}

resource "google_compute_subnetwork" "vpc_subnetwork_public" {
  name = "${var.prefix}-subnetwork-public"

  # A reference to the vpc network.
  network = google_compute_network.vpc.self_link

  # When `private_ip_google_access` is enabled, VMs in this subnetwork
  # without external IP addresses can access Google APIs and services by
  # using Private Google Access.
  private_ip_google_access = true

  # The range of internal addresses that are owned by this public subnetwork.
  ip_cidr_range = cidrsubnet(
    var.cidr_block,
    var.cidr_subnetwork_bits,
    0
  )

  # Configuration for secondary IP ranges for VM instances contained in
  # this public subnetwork.
  secondary_ip_range {
    range_name = "public-services"
    ip_cidr_range = cidrsubnet(
      var.secondary_cidr_block,
      var.secondary_cidr_subnetwork_bits,
      0
    )
  }

}

resource "google_compute_subnetwork" "vpc_subnetwork_private" {
  name = "${var.prefix}-subnetwork-private"
  region  = var.region

  # A reference to the vpc network.
  network = google_compute_network.vpc.self_link

  # When `private_ip_google_access` is enabled, VMs in this subnetwork
  # without external IP addresses can access Google APIs and services by
  # using Private Google Access.
  private_ip_google_access = true

  # The range of internal addresses that are owned by this private subnetwork.
  ip_cidr_range = cidrsubnet(
    var.cidr_block,
    var.cidr_subnetwork_bits,
    1
  )

  # Configuration for secondary IP ranges for VM instances contained in
  # this private subnetwork.
  secondary_ip_range {
    range_name = "private-services"
    ip_cidr_range = cidrsubnet(
      var.secondary_cidr_block,
      var.secondary_cidr_subnetwork_bits,
      1
    )
  }

}


# Cloud NAT (network address translation) allows Google Cloud VM instances
# without external IP addresses and private Google Kubernetes Engine (GKE) clusters
# to send outbound packets to the internet and receive any corresponding
# established inbound response packets.
resource "google_compute_router_nat" "vpc_nat" {
  name = "${var.prefix}-nat"
  region  = var.region

  # The name of the Cloud Router in which this NAT will be configured.
  router  = google_compute_router.vpc_router.name

  # How external IPs should be allocated for this NAT.
  # - AUTO_ONLY only allows NAT IPs allocated by GCP
  # - MANUAL_ONLY only allows user-allocated NAT IP addresses
  nat_ip_allocate_option = "AUTO_ONLY"

  # How NAT should be configured per Subnetwork.
  # - ALL_SUBNETWORKS_ALL_IP_RANGES all of the IP ranges in every Subnetwork
  #   are allowed to Nat.
  # - ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES
  #   all of the primary IP ranges in every Subnetwork are allowed to Nat.
  # - LIST_OF_SUBNETWORKS a list of Subnetworks are allowed to Nat
  #   (needs to be specified below in the subnetwork field).
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  # Specifing all the subnetworks for with the NAT is used,
  # so public subnetwork can be excluded
  subnetwork {
    name = google_compute_subnetwork.vpc_subnetwork_private.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

}
