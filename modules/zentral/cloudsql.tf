resource "random_password" "db" {
  length = 17
}

resource "random_id" "master_db_suffix" {
  byte_length = 3
}

resource "google_sql_database_instance" "zentral" {
  name             = "ztl-master-${random_id.master_db_suffix.hex}"
  database_version = var.db_version

  settings {
    tier = var.db_tier
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
      require_ssl     = true
    }
    backup_configuration {
      enabled    = var.db_backup_enabled
      start_time = var.db_backup_start_time
      backup_retention_settings {
        retained_backups = var.db_backup_count
        retention_unit   = "COUNT"
      }
      point_in_time_recovery_enabled = var.db_point_in_time_recovery_enabled
      transaction_log_retention_days = var.db_transaction_log_retention_days
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
  name            = "zentral"
  instance        = google_sql_database_instance.zentral.name
  password        = random_password.db.result
  deletion_policy = var.destroy_all_resources ? "ABANDON" : null
}
