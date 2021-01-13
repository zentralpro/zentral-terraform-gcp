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
    provider = "gcloud"
    config = {
      GCE_PROJECT = var.project_id
    }
  }
}
