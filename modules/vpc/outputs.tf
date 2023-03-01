output "network_id" {
  value       = google_compute_network.zentral.id
  description = "The VPC network id"
}

output "network_name" {
  value       = google_compute_network.zentral.name
  description = "The VPC network name"
}

output "subnetwork_name" {
  value       = google_compute_subnetwork.subnetwork.name
  description = "The subnetwork name"
}

output "manual_nat_ip_addresses" {
  value       = google_compute_address.manual_nat.*.address
  description = "List of the manually managed NAT IP addresses"
}
