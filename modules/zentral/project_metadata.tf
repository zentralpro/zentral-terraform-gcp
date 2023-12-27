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

resource "google_compute_project_metadata_item" "auto_cachain" {
  key   = "zentral_auto_cachain"
  value = "UNDEFINED"

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

resource "google_compute_project_metadata_item" "mdm_cachain" {
  key   = "zentral_mdm_cachain"
  value = var.mdm_cachain
}

resource "google_compute_project_metadata_item" "distribute_tls_server_certs" {
  key   = "zentral_distribute_tls_server_certs"
  value = var.distribute_tls_server_certs
}

resource "google_compute_project_metadata_item" "nginx_http_realip" {
  key = "zentral_nginx_http_realip"
  value = jsonencode({
    set_real_ip_from = var.set_real_ip_from,
    real_ip_header   = var.real_ip_header == "UNDEFINED" ? null : var.real_ip_header
  })
}

resource "google_compute_project_metadata_item" "collect_nginx_access_log" {
  key   = "zentral_collect_nginx_access_log"
  value = var.collect_nginx_access_log ? "1" : "0"
}

resource "google_compute_project_metadata_item" "geolite2_account_id" {
  key   = "zentral_geolite2_account_id"
  value = var.geolite2_account_id
}

resource "google_compute_project_metadata_item" "ek_instance_count" {
  key   = "zentral_ek_instance_count"
  value = var.ek_instance_count
}

resource "google_compute_project_metadata_item" "datadog_site" {
  key   = "zentral_datadog_site"
  value = var.datadog_site
}

resource "google_compute_project_metadata_item" "datadog_service" {
  key   = "zentral_datadog_service"
  value = var.datadog_service
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

resource "google_compute_project_metadata_item" "smtp_allowed_recipient_domains" {
  key   = "zentral_smtp_allowed_recipient_domains"
  value = jsonencode(var.smtp_allowed_recipient_domains)
}

resource "google_compute_project_metadata_item" "crowdstrike_deb" {
  key   = "zentral_crowdstrike_deb"
  value = var.crowdstrike_deb
}

resource "google_compute_project_metadata_item" "xagt_deb" {
  key   = "zentral_xagt_deb"
  value = length(google_storage_bucket_object.xagt_deb) > 0 ? google_storage_bucket_object.xagt_deb[0].name : "UNDEFINED"
}

resource "google_compute_project_metadata_item" "xagt_config" {
  key   = "zentral_xagt_config"
  value = length(google_storage_bucket_object.xagt_config) > 0 ? google_storage_bucket_object.xagt_config[0].name : "UNDEFINED"
}

resource "google_compute_project_metadata_item" "nessus_deb" {
  key   = "zentral_nessus_deb"
  value = length(google_storage_bucket_object.nessus_deb) > 0 ? google_storage_bucket_object.nessus_deb[0].name : "UNDEFINED"
}

resource "google_compute_project_metadata_item" "nessus_groups" {
  key   = "zentral_nessus_groups"
  value = var.nessus_groups
}
