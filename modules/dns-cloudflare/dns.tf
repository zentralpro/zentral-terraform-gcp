data "cloudflare_zones" "this" {
  filter {
    name = join(".", slice(split(".", var.fqdn), 1, length(split(".", var.fqdn))))
  }
}

resource "cloudflare_record" "fqdn" {
  zone_id = lookup(data.cloudflare_zones.this.zones[0], "id")
  name    = element(split(".", var.fqdn), 0)
  type    = "A"
  value   = var.lb_ip
  ttl     = var.ttl
}

resource "cloudflare_record" "fqdn_mtls" {
  count   = var.fqdn_mtls != "UNDEFINED" ? 1 : 0
  zone_id = lookup(data.cloudflare_zones.this.zones[0], "id")
  name    = element(split(".", var.fqdn_mtls), 0)
  type    = "A"
  value   = var.lb_ip
  ttl     = var.ttl
}

