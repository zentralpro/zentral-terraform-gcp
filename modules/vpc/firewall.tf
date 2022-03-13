# allow IAP to connect to the ssh tagged instances
resource "google_compute_firewall" "allow-iap-ssh" {
  name        = "allow-iap-ssh"
  description = "Allow SSH to 'ssh' tagged instances through IAP"
  network     = google_compute_network.zentral.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]

  target_tags = ["ssh"]
}

# allow http and https connection to the web tagged instances
resource "google_compute_firewall" "allow-http-https" {
  name        = "allow-http-https"
  description = "Allow 80 and 443 to 'web' tagged instances"
  network     = google_compute_network.zentral.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["web"]
}

# allow network load balancer health checks to the web tagged instances
# see https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges
resource "google_compute_firewall" "allow-network-lb-health-checks" {
  name        = "allow-network-lb-health-checks"
  description = "Allow the network LB to do health checks on the web instances"
  network     = google_compute_network.zentral.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "209.85.152.0/22",
    "209.85.204.0/22",
  ]

  target_tags = ["web"]
}

# allow autohealing health checks to the web tagged instances
# see https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges
resource "google_compute_firewall" "allow-web-mig-health-checks" {
  name        = "allow-web-mig-health-checks"
  description = "Allow the web managed instance group to do health checks"
  network     = google_compute_network.zentral.name

  allow {
    protocol = "tcp"
    ports    = ["8081"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  target_tags = ["web"]
}

# allow autohealing health checks to the worker tagged instances
# the first worker prometheus metrics endpoint is used
# see https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges
resource "google_compute_firewall" "allow-worker-mig-health-checks" {
  name        = "allow-worker-mig-health-checks"
  description = "Allow the worker managed instance group to do health checks"
  network     = google_compute_network.zentral.name

  allow {
    protocol = "tcp"
    ports    = ["9910"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  target_tags = ["worker"]
}

# allow connections from the web instances to the elastic instances
resource "google_compute_firewall" "allow-elastic" {
  name        = "allow-elastic"
  description = "Allow 9200 to 'elastic' tagged instances"
  network     = google_compute_network.zentral.name

  allow {
    protocol = "tcp"
    ports    = ["9200"]
  }

  source_tags = ["monitoring", "web", "worker"]
  target_tags = ["elastic"]
}

# allow connections from the web instances to the kibana instances
resource "google_compute_firewall" "allow-kibana" {
  name        = "allow-kibana"
  description = "Allow 5601 from 'web' to 'kibana' tagged instances"
  network     = google_compute_network.zentral.name

  allow {
    protocol = "tcp"
    ports    = ["5601"]
  }

  source_tags = ["web"]
  target_tags = ["elastic"]
}

# allow prometheus scraping
resource "google_compute_firewall" "allow-prometheus-scraping" {
  name        = "allow-prometheus-scraping"
  description = "Allow 9900-9950 from 'monitoring' to targets"
  network     = google_compute_network.zentral.name

  allow {
    protocol = "tcp"
    ports    = ["9900-9950"]
  }

  source_tags = ["monitoring"]
  target_tags = ["web", "worker"]
}

# allow proxying for monitoring
resource "google_compute_firewall" "allow-monitoring-proxying" {
  name        = "allow-monitoring-proxying"
  description = "Allow 8000-80001 from 'web' to 'monitoring'"

  network = google_compute_network.zentral.name

  allow {
    protocol = "tcp"
    ports    = ["8000-8001"]
  }

  source_tags = ["web"]
  target_tags = ["monitoring"]
}
