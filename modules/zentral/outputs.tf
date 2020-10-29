output "fqdn" {
  value = var.fqdn
}

output "fqdn_mtls" {
  value = var.fqdn_mtls
}

output "lb_ip" {
  value = google_compute_address.zentral.address
}

output "dist_bucket" {
  value = google_storage_bucket.dist.name
}
