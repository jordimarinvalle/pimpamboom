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


# ---
# VPC
# ---
module "vpc" {

  source = "./modules/vpc"

  prefix  = "${var.name}-network"
  project = var.project
  region  = var.region

  cidr_block = var.vpc_cidr_block
  cidr_subnetwork_bits = var.vpc_cidr_subnetwork_bits
  secondary_cidr_block = var.vpc_secondary_cidr_block
  secondary_cidr_subnetwork_bits = var.vpc_secondary_cidr_subnetwork_bits

}
