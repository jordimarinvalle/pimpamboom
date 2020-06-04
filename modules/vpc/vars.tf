variable "prefix" {
  description = "A prefix used in resource's names to ensure uniqueness"
  type        = string
}

variable "region" {
  description = "The region for the network."
  type        = string
}

# cidr_subnetwork_bits will have to be adjusted
# in case that network size is changed
variable "cidr_block" {
  description = "Primary CIDR block"
  type        = string
  default     = "10.10.0.0/16"
}

variable "cidr_subnetwork_bits" {
  description = "The number of additional bits with which to extend the cidr block"
  type        = number
  default     = 4
}

# secondary_cidr_subnetwork_bits will have to be adjusted
# in case that network size is changed
variable "secondary_cidr_block" {
  description = "Secondary CIDR block"
  type        = string
  default     = "10.20.0.0/16"
}

variable "secondary_cidr_subnetwork_bits" {
  description = "The number of additional bits with which to extend the cidr block"
  type        = number
  default     = 4
}
