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


# --------
# FIREWALL
# --------
module "firewall" {

  source = "./modules/firewall"

  prefix  = "${var.name}-network"
  network  = module.vpc.network

}

# ------------
# VM INSTANCES
# ------------
data "google_compute_zones" "available" {
  status = "UP"
}

resource "google_compute_instance" "public_with_ip" {

  name  = "${var.name}-instance-public-with-ip"
  zone  = data.google_compute_zones.available.names[0]
  machine_type = local.machine_type_micro

  # `true` will allow to update (resize the VM machine_type) after initial creation
  allow_stopping_for_update = true

  tags = [module.firewall.tag_public]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork = module.vpc.public_subnetwork

    # IPs via which this instance can be accessed via the Internet.
    # Omit to ensure that the instance is not accessible from the Internet.
    access_config {
      // Ephemeral IP
    }
  }
}
