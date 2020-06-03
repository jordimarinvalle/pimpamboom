variable "project" {
  description = "The project ID where all resources will be launched."
  type        = string
}

variable "name" {
  description = "Cluster name mainly used for labeling resourses."
  type        = string
}

variable "location" {
  description = "The location (region or zone) of the GKE cluster."
  type        = string
  default     = "europe-west4"
}

variable "region" {
  description = "The region for the network and firewall rules. If the GKE cluster is regional, this must be the same region. Otherwise, it should be the region of the zone."
  type        = string
  default     = "europe-west4"
}


# VPC
#####

variable "vpc_cidr_block" {
  description = "VPC CIDR block, 65534 net host ips."
  type        = string
  default     = "10.10.0.0/16"
}

variable "vpc_cidr_subnetwork_bits" {
  description = "The number of additional bits with which to extend the cidr block."
  type        = number
  default     = 4
}

variable "vpc_secondary_cidr_block" {
  description = "VPC secondary CIDR block, 65534 net host ips."
  type        = string
  default     = "10.20.0.0/16"
}

variable "vpc_secondary_cidr_subnetwork_bits" {
  description = "The number of additional bits with which to extend the secondary cidr block."
  type        = number
  default     = 4
}
