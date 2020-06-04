# -----------------------------------------------------------------------
# Deploy a GKE private cluster in GCP with a Load Balancer in front of it
# -----------------------------------------------------------------------

terraform {
  required_version = ">= 0.12.24"
}

provider "google" {

  credentials = file("account.json")
  project     = var.project
  region      = var.region

  scopes = [

    # Default scopes
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",

    # Required for google_client_openid_userinfo
    "https://www.googleapis.com/auth/userinfo.email",
  ]

}

# Get the email of the service account used by the provider to authenticate
# with GCP.
data "google_client_openid_userinfo" "user" {}

# ---
# VPC
# ---
module "vpc" {

  source = "./modules/vpc"

  prefix  = "${var.name}-network"
  region  = var.region

  cidr_block = var.vpc_cidr_block
  cidr_subnetwork_bits = var.vpc_cidr_subnetwork_bits
  secondary_cidr_block = var.vpc_secondary_cidr_block
  secondary_cidr_subnetwork_bits = var.vpc_secondary_cidr_subnetwork_bits

}


# --------
# FIREWALL
# --------
module "firewall" {

  source = "./modules/firewall"

  prefix  = "${var.name}-network"
  network  = module.vpc.network

}


# ---
# GKE
# ---
module "gke" {

  source = "./modules/gke"

  prefix  = "${var.name}-gke"
  location = var.location

  # GKE cluster will be deployed in a private network,
  # outbound internet access will be provided by NAT
  network = module.vpc.network
  subnetwork = module.vpc.private_subnetwork

  # Configuration for private clusters with private nodes
  enable_private_nodes = true
  enable_private_endpoint = false
  master_ipv4_cidr_block = var.gke_master_ipv4_cidr_block

  # Needed to set the range for ip_aliases, GCP will pick the IPs within the range
  cluster_secondary_range_name = module.vpc.private_subnetwork_secondary_range_name

  # NODE POOL
  ###########
  node_machine_type = var.gke_pool_node_machine_type
  node_tag_network_private = module.firewall.tag_private
  service_account_email = data.google_client_openid_userinfo.user.email

}
