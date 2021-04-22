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

# IP addresses for the nat router
resource "google_compute_address" "manual_nat" {
  count  = var.manual_nat_ip_address_count
  name   = "ztl-manual-nat-ip-${count.index}"
  region = data.google_client_config.current.region
}

# configure nat with router
resource "google_compute_router_nat" "nat-config" {
  name   = "ztl-nat-config"
  router = google_compute_router.nat-router.name
  region = data.google_client_config.current.region

  nat_ip_allocate_option = var.manual_nat_ip_address_count > 0 ? "MANUAL_ONLY" : "AUTO_ONLY"
  nat_ips                = var.manual_nat_ip_address_count > 0 ? google_compute_address.manual_nat.*.self_link : null

  # https://cloud.google.com/nat/docs/overview#specs-rfcs
  enable_endpoint_independent_mapping = false

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.subnetwork.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
