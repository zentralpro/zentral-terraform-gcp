resource "google_redis_instance" "cache" {
  name           = "ztl-redis"
  memory_size_gb = 1

  redis_version = "REDIS_5_0"

  tier        = "BASIC"
  location_id = data.google_client_config.current.zone

  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  authorized_network = var.network_id

  depends_on = [
    google_service_networking_connection.private_connection
  ]
}
