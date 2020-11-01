resource "google_compute_https_health_check" "web" {
  name         = "ztl-web-health-check"
  request_path = "/health_check/"
  host         = var.fqdn
  port         = 443
}

resource "google_compute_target_pool" "web" {
  name   = "ztl-web-target-pool"
  region = data.google_client_config.current.region

  health_checks = [
    google_compute_https_health_check.web.self_link,
  ]
}

resource "google_compute_address" "zentral" {
  name   = "ztl-static-ip"
  region = data.google_client_config.current.region
}

resource "google_compute_forwarding_rule" "web" {
  name                  = "ztl-web-forwarding-rule"
  region                = data.google_client_config.current.region
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "1-65535"
  ip_address            = google_compute_address.zentral.address

  target = google_compute_target_pool.web.self_link
}
