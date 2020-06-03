output "network" {
  description = "A reference (self_link) to the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "public_subnetwork" {
  description = "A reference (self_link) to the public subnetwork"
  value       = google_compute_subnetwork.vpc_subnetwork_public.self_link
}

output "public_subnetwork_name" {
  description = "Name of the public subnetwork"
  value       = google_compute_subnetwork.vpc_subnetwork_public.name
}

output "private_subnetwork" {
  description = "A reference (self_link) to the private subnetwork"
  value       = google_compute_subnetwork.vpc_subnetwork_private.self_link
}

output "private_subnetwork_name" {
  description = "Name of the private subnetwork"
  value       = google_compute_subnetwork.vpc_subnetwork_private.name
}

output "private_subnetwork_secondary_cidr_block" {
  value = google_compute_subnetwork.vpc_subnetwork_private.secondary_ip_range[0].ip_cidr_range
}

output "private_subnetwork_secondary_range_name" {
  value = google_compute_subnetwork.vpc_subnetwork_private.secondary_ip_range[0].range_name
}
