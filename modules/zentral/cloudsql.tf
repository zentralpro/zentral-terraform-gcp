resource "random_password" "db" {
  length = 17
}

resource "random_id" "master_db_suffix" {
  byte_length = 3
}

resource "google_sql_database_instance" "zentral" {
  name             = "ztl-master-${random_id.master_db_suffix.hex}"
  database_version = "POSTGRES_12"

  settings {
    tier      = var.db_tier
    disk_size = 10
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }
  }

  deletion_protection = var.destroy_all_resources != true

  depends_on = [
    google_service_networking_connection.private_connection
  ]
}

resource "google_sql_database" "zentral" {
  name     = "zentral"
  instance = google_sql_database_instance.zentral.name
}

resource "google_sql_user" "zentral" {
  name     = "zentral"
  instance = google_sql_database_instance.zentral.name
  password = random_password.db.result
}
