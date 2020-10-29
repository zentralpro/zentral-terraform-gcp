resource "google_redis_instance" "cache" {
  name           = "ztl-redis"
  memory_size_gb = 1

  redis_version = "REDIS_5_0"

  tier        = "BASIC"
  location_id = var.default_zone

  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  authorized_network = var.network_id
}
