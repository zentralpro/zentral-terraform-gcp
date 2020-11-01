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

# allow health checks to the web tagged instances
# see https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges
resource "google_compute_firewall" "allow-network-lb-health-checks" {
  name        = "allow-network-lb-health-checks"
  description = "Allow the network LB to do health checks on the web instances"
  network     = google_compute_network.zentral.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["35.191.0.0/16",
    "209.85.152.0/22",
  "209.85.204.0/22"]

  target_tags = ["web"]
}

# allow connections from the web instances to the elastic instances
resource "google_compute_firewall" "allow-elastic" {
  name        = "allow-elastic"
  description = "Allow 9200 from 'web' to 'elastic' tagged instances"
  network     = google_compute_network.zentral.name

  allow {
    protocol = "tcp"
    ports    = ["9200"]
  }

  source_tags = ["web", "worker"]
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