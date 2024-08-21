locals {
  configure_igw = var.ident_gateway_config_json == "UNDEFINED" ? false : true
}

#
# IDent Gateway config
#

resource "google_compute_project_metadata_item" "ident_gateway_config_json" {
  key   = "zentral_ident_gateway_config_json"
  value = var.ident_gateway_config_json
}

#
# IDent Gateway challenge
#

resource "random_password" "ident_gateway_challenge" {
  count  = local.configure_igw ? 1 : 0
  length = 17
}

resource "google_secret_manager_secret" "ident_gateway_challenge" {
  count = local.configure_igw ? 1 : 0

  secret_id = "ztl-ident-gateway-challenge"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# IDent Gateway challenge read access for web service accounts
resource "google_secret_manager_secret_iam_member" "ident_gateway_challenge_web" {
  count = local.configure_igw ? 1 : 0

  secret_id = google_secret_manager_secret.ident_gateway_challenge[0].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# IDent Gateway challenge value
resource "google_secret_manager_secret_version" "ident_gateway_challenge" {
  count = local.configure_igw ? 1 : 0

  secret      = google_secret_manager_secret.ident_gateway_challenge[0].id
  secret_data = random_password.ident_gateway_challenge[0].result
}


#
# IDent Gateway RA certificate and private key
#

resource "tls_private_key" "igw_ra" {
  count     = local.configure_igw ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "igw_ra" {
  count           = local.configure_igw ? 1 : 0
  private_key_pem = tls_private_key.igw_ra[0].private_key_pem

  subject {
    common_name = "Zentral"
  }

  validity_period_hours = 87600 # TODO: 10 years

  allowed_uses = [
    "content_commitment",
    "email_protection",
    "digital_signature",
  ]
}

# IDent Gateway RA private key secret
resource "google_secret_manager_secret" "igw_ra_privkey" {
  count = local.configure_igw ? 1 : 0

  secret_id = "ztl-igw-ra-privkey"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# IDent Gateway RA private key read access for web service accounts
resource "google_secret_manager_secret_iam_member" "igw_ra_privkey_web" {
  count = local.configure_igw ? 1 : 0

  secret_id = google_secret_manager_secret.igw_ra_privkey[0].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# IDent Gateway RA private key value
resource "google_secret_manager_secret_version" "igw_ra_privkey" {
  count = local.configure_igw ? 1 : 0

  secret      = google_secret_manager_secret.igw_ra_privkey[0].id
  secret_data = tls_private_key.igw_ra[0].private_key_pem
}

# Project metadata

resource "google_compute_project_metadata_item" "igw_ra_cert" {
  key   = "zentral_igw_ra_cert"
  value = length(tls_self_signed_cert.igw_ra) > 0 ? tls_self_signed_cert.igw_ra[0].cert_pem : "UNDEFINED"
}
