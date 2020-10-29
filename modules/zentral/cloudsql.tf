resource "random_password" "db" {
  length = 17
}

resource "google_sql_database_instance" "zentral" {
  name             = "ztl-master"
  database_version = "POSTGRES_12"

  settings {
    tier = "db-g1-small"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }
  }

  deletion_protection = var.destroy_all_resources != true
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
