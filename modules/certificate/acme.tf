locals {
  dns_challenge_provider = var.gcp_project_id != "UNDEFINED" ? "gcloud" : "cloudflare"
  dns_challenge_config   = var.gcp_project_id != "UNDEFINED" ? { GCE_PROJECT = var.gcp_project_id } : { CF_DNS_API_TOKEN = var.cloudflare_api_token }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "acme_registration" "this" {
  account_key_pem = tls_private_key.this.private_key_pem
  email_address   = var.registration_email
}

resource "acme_certificate" "this" {
  account_key_pem           = acme_registration.this.account_key_pem
  common_name               = element(var.fqdns, 0)
  subject_alternative_names = var.fqdns

  dns_challenge {
    provider = local.dns_challenge_provider
    config   = local.dns_challenge_config
  }
}
