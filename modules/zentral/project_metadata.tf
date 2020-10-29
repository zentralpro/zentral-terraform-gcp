resource "google_compute_project_metadata_item" "admin_email" {
  key   = "zentral_admin_email"
  value = var.admin_email
}

resource "google_compute_project_metadata_item" "admin_username" {
  key   = "zentral_admin_username"
  value = var.admin_username
}

resource "google_compute_project_metadata_item" "base_json" {
  key   = "zentral_base_json"
  value = var.base_json
}

resource "google_compute_project_metadata_item" "fqdn" {
  key   = "zentral_fqdn"
  value = var.fqdn
}

resource "google_compute_project_metadata_item" "fqdn_mtls" {
  key   = "zentral_fqdn_mtls"
  value = var.fqdn_mtls
}

resource "google_compute_project_metadata_item" "tls_cert" {
  key   = "zentral_tls_cert"
  value = var.tls_cert

  # not managed by tf
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "google_compute_project_metadata_item" "tls_chain" {
  key   = "zentral_tls_chain"
  value = var.tls_chain

  # not managed by tf
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "google_compute_project_metadata_item" "tls_cachain" {
  key   = "zentral_tls_cachain"
  value = var.tls_cachain
}

resource "google_compute_project_metadata_item" "distribute_tls_server_certs" {
  key   = "zentral_distribute_tls_server_certs"
  value = var.distribute_tls_server_certs
}

resource "google_compute_project_metadata_item" "geolite2_account_id" {
  key   = "zentral_geolite2_account_id"
  value = var.geolite2_account_id
}

resource "google_compute_project_metadata_item" "datadog_site" {
  key   = "zentral_datadog_site"
  value = var.datadog_site
}

resource "google_compute_project_metadata_item" "vm_dns_setting" {
  key   = "VmDnsSetting"
  value = "ZonalPreferred"
}

resource "google_compute_project_metadata_item" "default_from_email" {
  key   = "zentral_default_from_email"
  value = var.default_from_email
}

resource "google_compute_project_metadata_item" "smtp_relay_host" {
  key   = "zentral_smtp_relay_host"
  value = var.smtp_relay_host
}

resource "google_compute_project_metadata_item" "smtp_relay_user" {
  key   = "zentral_smtp_relay_user"
  value = var.smtp_relay_user
}
