output "network_id" {
  value       = google_compute_network.zentral.id
  description = "The VPC network id"
}

output "network_name" {
  value       = google_compute_network.zentral.name
  description = "The VPC network name"
}
