variable "prefix" {
  description = "A prefix used in resource names to ensure uniqueness"
  type        = string
}

variable "location" {
  description = "The location (region or zone) to host the cluster in"
  type        = string
}

variable "network" {
  description = "A reference (self link) to the VPC network to host the cluster in"
  type        = string
}

variable "subnetwork" {
  description = "A reference (self link) to the subnetwork to host the cluster in"
  type        = string
}

variable "cluster_secondary_range_name" {
  description = "The name of the secondary range within the subnetwork for the cluster to use"
  type        = string
}

variable "enable_private_nodes" {
  type    = bool
  default = true
}

variable "enable_private_endpoint" {
  type    = bool
  default = false
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation (size must be /28) to use for the hosted master network. This range will be used for assigning internal IP addresses to the master or set of masters, as well as the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network."
  type        = string
  default     = "10.5.0.0/28"
}


# GKE NODE POOL
###############

variable "min_node_count" {
  description = "The autoscaling minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count."
  type        = string
  default     = "1"
}

variable "max_node_count" {
  description = "The autoscaling maximum number of nodes in the NodePool. Must be >= min_node_count."
  type        = string
  default     = "3"
}


# GKE NODE CONFIG
#################

variable "node_image_type" {
  description = "The image type to use for this node. Note that changing the image type will delete and recreate all nodes in the node pool."
  type        = string
  default     = "COS"
}

variable "node_machine_type" {
  description = "The name of a Google Compute Engine machine type. Defaults to n1-standard-1"
  type        = string
  default     = "n1-standard-1"
}

variable "node_tag_network_private" {
  description = "`node_tag_network_private` is a tag used to target a private network firewall rule(s)."
  type        = string
}

variable "node_disk_size" {
  description = "Size of the disk attached to each node, specified in GB. The smallest allowed disk size is 10GB. Defaults to 100GB."
  type        = string
  default     = "10"
}

variable "node_disk_type" {
  description = "Type of the disk attached to each node (e.g. 'pd-standard' or 'pd-ssd'). If unspecified, the default disk type is 'pd-standard'"
  type        = string
  default     = "pd-standard"
}

variable "node_preemptible" {
  description = "Preemptible VMs are Compute Engine VM instances that last a maximum of 24 hours and provide no availability guarantees. Preemptible VMs are priced lower than standard Compute Engine VMs and offer the same machine types and options."
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "The Google Cloud Platform Service Account to be used by the node VMs"
  type        = string
}
