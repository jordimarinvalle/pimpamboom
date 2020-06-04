resource "google_container_cluster" "cluster" {

  provider = google

  name        = "${var.prefix}-cluster"
  location    = var.location
  network     = var.network
  subnetwork  = var.subnetwork

  # google_container_node_pool Terraform resource will be created, so:
  # - `remove_default_node_pool` needs to be set to true
  # - `initial_node_count` to at least 1
  remove_default_node_pool = true
  initial_node_count = 1

  # `ip_allocation_policy` configuration of cluster IP allocation also
  # enables IP aliasing, making the cluster VPC-native instead of routes-based.
  # https://cloud.google.com/vpc/docs/alias-ip
  #
  # GCP will pick the IPs withing the ranges provided, so arguments
  # `cluster_ipv4_cidr_block` and `services_ipv4_cidr_block` are not provided
  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.cluster_secondary_range_name
  }

  # Configuration for private clusters with private nodes
  # See https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters
  private_cluster_config {

    # Enables the private cluster feature, creating a private endpoint on
    # the cluster. In a private cluster, nodes only have RFC 1918 private
    # addresses and communicate with the master's private endpoint via
    # private networking.
    enable_private_nodes = var.enable_private_nodes

    # When true, the cluster's private endpoint is used as the cluster endpoint
    # and access through the public endpoint is disabled.
    # When false, either endpoint can be used.
    # This field only applies to private clusters, when `enable_private_nodes` is true.
    enable_private_endpoint = var.enable_private_endpoint

    # The IP range in CIDR notation to use for the hosted master network. This
    # range will be used for assigning private IP addresses to the cluster
    # master(s) and the ILB VIP. This range must not overlap with any other
    # ranges in use within the cluster's network, and it must be a /28 subnet.
    # See Private Cluster Limitations for more details,
    # https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters#req_res_lim
    # This field only applies to private clusters, when `enable_private_nodes`
    # is true.
    master_ipv4_cidr_block = var.master_ipv4_cidr_block

  }

  # Configuration for addons supported by GKE
  addons_config {

    # The status of the HTTP (layer 7) load balancing controller addon, which
    # makes it easy to set up HTTP load balancers for services in a cluster.
    # It is enabled by default; set disabled = true to disable.
    http_load_balancing {
      disabled = false
    }

    # Increases or decreases the number of replica pods a replication
    # controller has based on the resource usage of the existing pods.
    # It ensures that a Heapster pod is running in the cluster, which is
    # also used by the Cloud Monitoring service.
    # It is enabled by default; set disabled = true to disable.
    horizontal_pod_autoscaling {
      disabled = false
    }

    # This must be enabled in order to enable network policy for the nodes.
    # To enable this, you must also define a network_policy block, otherwise
    # nothing will happen. It can only be disabled if the nodes already
    # do not have network policies enabled.
    # Defaults to disabled; set disabled = false to enable.
    network_policy_config {
      disabled = false
    }

  }

  # Calico’s network policy engine formed the original reference implementation
  # of Kubernetes network policy during the development of the API.
  # https://github.com/GoogleCloudPlatform/gke-network-policy-demo
  network_policy {
    enabled   = true
    provider  = "CALICO"
  }

}


resource "google_container_node_pool" "node_pool" {

  provider = google

  name      = "${var.prefix}-node-pool"
  location  = var.location
  cluster   = google_container_cluster.cluster.name

  initial_node_count = "1"

  # Autoscaler configuration to adjust the size of the node pool to the current
  # cluster usage.
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  # Node management configuration, wherein auto-repair and auto-upgrade is
  # configured.
  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }

  # Check out all `node_config` attributes at `container_cluster` resource
  # https://www.terraform.io/docs/providers/google/r/container_cluster.html
  node_config {

    image_type   = var.node_image_type
    machine_type = var.node_machine_type

    labels = {
      gke-node-pool = "true"
    }

    tags = [
      var.node_tag_network_private,
    ]

    disk_size_gb = var.node_disk_size
    disk_type    = var.node_disk_type
    preemptible  = var.node_preemptible

    # The Google Cloud Platform Service Account to be used by the node VMs
    service_account = var.service_account_email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  # Terraform detects any difference in the current settings of a real
  # infrastructure object and plans to update the remote object to match
  # configuration.
  # Ignore changes to `initial_node_count` because that is a mandatory setting
  # which the total number of nodes will differ to the real configuration.
  lifecycle {
    ignore_changes = [initial_node_count]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

}
