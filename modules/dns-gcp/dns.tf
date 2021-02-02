resource "google_dns_record_set" "fqdn" {
  name         = format("%s.", var.fqdn)
  managed_zone = var.managed_zone_name
  type         = "A"
  ttl          = 60
  rrdatas      = [var.lb_ip]
}

resource "google_dns_record_set" "fqdn_mtls" {
  count = var.fqdn_mtls == "UNDEFINED" ? 0 : 1

  name         = format("%s.", var.fqdn_mtls)
  managed_zone = var.managed_zone_name
  type         = "A"
  ttl          = 60
  rrdatas      = [var.lb_ip]
}
