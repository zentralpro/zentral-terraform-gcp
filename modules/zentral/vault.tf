# Auto unseal KMS for Vault
# see https://github.com/hashicorp/vault-guides/blob/master/operations/gcp-kms-unseal/main.tf

resource "google_kms_key_ring" "vault_kms_unseal" {
  count = var.vault_instance_count > 0 ? 1 : 0

  name     = "ztl-vault-kms-auto-unseal"
  location = data.google_client_config.current.region
}

resource "google_kms_crypto_key" "vault_kms_unseal" {
  count = var.vault_instance_count > 0 ? 1 : 0

  name            = "ztl-vault-kms-auto-unseal"
  key_ring        = google_kms_key_ring.vault_kms_unseal[0].id
  rotation_period = "7776000s" # 90 days TODO: hard-coded
}

# Allow vault instance to use the KMS key ring for auto-unseal

# see https://developer.hashicorp.com/vault/docs/secrets/key-management/gcpkms#authentication
# 2023-12-25 !!! some were missing !!!
resource "google_project_iam_custom_role" "vault_kms_unseal" {
  count = var.vault_instance_count > 0 ? 1 : 0

  role_id = "ztlVaultKMSUnseal"
  title   = "Zentral Vault KMS unseal"
  permissions = [
    "cloudkms.importJobs.create",
    "cloudkms.importJobs.get",
    "cloudkms.cryptoKeys.create",
    "cloudkms.cryptoKeys.get",
    "cloudkms.cryptoKeys.update",
    "cloudkms.cryptoKeyVersions.create",
    "cloudkms.cryptoKeyVersions.destroy",
    "cloudkms.cryptoKeyVersions.list",
    "cloudkms.cryptoKeyVersions.update",
    "cloudkms.cryptoKeyVersions.useToDecrypt",
    "cloudkms.cryptoKeyVersions.useToEncrypt",
  ]
}

resource "google_kms_key_ring_iam_binding" "vault_kms_unseal" {
  count = var.vault_instance_count > 0 ? 1 : 0

  key_ring_id = google_kms_key_ring.vault_kms_unseal[0].id
  role        = google_project_iam_custom_role.vault_kms_unseal[0].id
  members = [
    "serviceAccount:${google_service_account.vault[0].email}"
  ]
}

# Project metadata

resource "google_compute_project_metadata_item" "vault_kms_unseal_key_ring" {
  key   = "zentral_vault_kms_unseal_key_ring"
  value = length(google_kms_key_ring.vault_kms_unseal) > 0 ? google_kms_key_ring.vault_kms_unseal[0].name : "UNDEFINED"
}

resource "google_compute_project_metadata_item" "vault_kms_unseal_crypto_key" {
  key   = "zentral_vault_kms_unseal_crypto_key"
  value = length(google_kms_crypto_key.vault_kms_unseal) > 0 ? google_kms_crypto_key.vault_kms_unseal[0].name : "UNDEFINED"
}
