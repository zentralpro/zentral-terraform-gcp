# KMS for the Zentral secret engine
# see https://docs.zentral.io/en/latest/configuration/secret_engines/#google-cloud-key-management

resource "google_kms_key_ring" "secret_engine" {
  name     = "ztl-secret-engine"
  location = data.google_client_config.current.region
}

resource "google_kms_crypto_key" "secret_engine" {
  name            = "ztl-secret-engine"
  key_ring        = google_kms_key_ring.secret_engine.id
  rotation_period = "7776000s" # 90 days TODO: hard-coded
}

# Permissions for the web and worker instances

resource "google_kms_key_ring_iam_binding" "secret_engine" {
  key_ring_id = google_kms_key_ring.secret_engine.id
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:${google_service_account.web.email}",
    "serviceAccount:${google_service_account.worker.email}"
  ]
}

# Project metadata

resource "google_compute_project_metadata_item" "secret_engine_kms_key_ring" {
  key   = "zentral_secret_engine_kms_key_ring"
  value = google_kms_key_ring.secret_engine.name
}

resource "google_compute_project_metadata_item" "secret_engine_kms_crypto_key" {
  key   = "zentral_secret_engine_kms_crypto_key"
  value = google_kms_crypto_key.secret_engine.name
}
