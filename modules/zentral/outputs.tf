output "fqdn" {
  value = var.fqdn
}

output "fqdn_mtls" {
  value = var.fqdn_mtls
}

output "lb_ip" {
  value = google_compute_address.zentral.address
}
