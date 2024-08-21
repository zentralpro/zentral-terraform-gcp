data "cloudflare_zones" "this" {
  filter {
    name = join(".", slice(split(".", var.fqdn), 1, length(split(".", var.fqdn))))
  }
}

locals {
  zone_id = lookup(data.cloudflare_zones.this.zones[0], "id")
}

provider "cloudflare" {
  api_token = var.api_token
}

resource "cloudflare_record" "fqdn" {
  zone_id = local.zone_id
  name    = element(split(".", var.fqdn), 0)
  type    = "A"
  content = var.lb_ip
  ttl     = var.proxied ? 1 : var.ttl
  proxied = var.proxied
}

resource "cloudflare_record" "fqdn_mtls" {
  count   = var.fqdn_mtls != "UNDEFINED" ? 1 : 0
  zone_id = local.zone_id
  name    = element(split(".", var.fqdn_mtls), 0)
  type    = "A"
  content = var.lb_ip
  ttl     = var.proxied ? 1 : var.ttl
  proxied = var.proxied
}
