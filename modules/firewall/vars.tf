variable "prefix" {
  description = "A prefix used in resource's names to ensure uniqueness"
  type        = string
}

variable "network" {
  description = "A reference (self_link) to the VPC network"
  type        = string
}
