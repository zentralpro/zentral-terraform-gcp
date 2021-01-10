# create a dedicated VPC network for zentral
resource "google_compute_network" "zentral" {
  name                    = "zentral"
  auto_create_subnetworks = false
}

# add a subnetwork in the provider region
resource "google_compute_subnetwork" "subnetwork" {
  name = format(
    "%s-%s",
    google_compute_network.zentral.name,
    data.google_client_config.current.region,
  )
  ip_cidr_range            = var.subnet
  region                   = data.google_client_config.current.region
  private_ip_google_access = true
  network                  = google_compute_network.zentral.id
}


# configure nat to allow instances without public addresses
# to connect to the web

# add data router
resource "google_compute_router" "nat-router" {
  name    = "ztl-nat-router"
  region  = data.google_client_config.current.region
  network = google_compute_network.zentral.name
}

# configure nat with router
resource "google_compute_router_nat" "nat-config" {
  name                               = "ztl-nat-config"
  router                             = google_compute_router.nat-router.name
  region                             = data.google_client_config.current.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
