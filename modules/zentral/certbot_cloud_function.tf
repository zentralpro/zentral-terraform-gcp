# service account for the certbot cloud function
resource "google_service_account" "certbot" {
  count        = var.certbot_cloud_function ? 1 : 0
  account_id   = "ztl-certbot-service-account"
  display_name = "Zentral certbot service account"
  description  = "Service account for the zentral certbot cloud function"
}

# role with extra permissions to get and set the project metadata
resource "google_project_iam_custom_role" "certbot" {
  count   = var.certbot_cloud_function ? 1 : 0
  role_id = "ztlCertbot"
  title   = "Zentral certbot role"
  permissions = [
    "compute.globalOperations.get",
    "compute.projects.get",
    "compute.projects.setCommonInstanceMetadata",
    "iam.serviceAccounts.actAs",
  ]
}

# bind the role to the instance service account
resource "google_project_iam_binding" "certbot" {
  count = var.certbot_cloud_function ? 1 : 0
  role  = google_project_iam_custom_role.certbot[0].id

  members = [
    "serviceAccount:${google_service_account.certbot[0].email}",
  ]
}

# cloudflare_api_token secret
resource "google_secret_manager_secret" "cloudflare_api_token" {
  count     = var.cloudflare_api_token != "UNDEFINED" ? 1 : 0
  secret_id = "ztl-cloudflare-api-token"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# cloudflare_api_token value
resource "google_secret_manager_secret_version" "cloudflare_api_token" {
  count       = var.cloudflare_api_token != "UNDEFINED" ? 1 : 0
  secret      = google_secret_manager_secret.cloudflare_api_token[0].id
  secret_data = var.cloudflare_api_token
}

# cloudflare_api_token read access for certbot service account
resource "google_secret_manager_secret_iam_member" "cloudflare_api_token" {
  count     = var.certbot_cloud_function && var.cloudflare_api_token != "UNDEFINED" ? 1 : 0
  secret_id = google_secret_manager_secret.cloudflare_api_token[0].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.certbot[0].email}"
}

# tls privkey read access for certbot service account
resource "google_secret_manager_secret_iam_member" "tls_privkey_certbot_r" {
  count     = var.certbot_cloud_function ? 1 : 0
  secret_id = google_secret_manager_secret.tls_privkey.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.certbot[0].email}"
}

# tls privkey write access for certbot service account
resource "google_secret_manager_secret_iam_member" "tls_privkey_certbot_w" {
  count     = var.certbot_cloud_function ? 1 : 0
  secret_id = google_secret_manager_secret.tls_privkey.secret_id
  role      = "roles/secretmanager.secretVersionAdder"
  member    = "serviceAccount:${google_service_account.certbot[0].email}"
}

# certbot cloud function pub/sub topic
resource "google_pubsub_topic" "certbot" {
  count = var.certbot_cloud_function ? 1 : 0
  name  = "ztl-certbot"
}

# scheduler schedule is first run + 5 min every day
resource "time_static" "certbot_schedule_origin" {
  count = var.certbot_cloud_function ? 1 : 0
}

# app engine app to unlock scheduler functionality
resource "google_app_engine_application" "certbot" {
  count       = var.certbot_cloud_function ? 1 : 0
  project     = data.google_client_config.current.project
  location_id = data.google_client_config.current.region == "us-central1" ? "us-central" : data.google_client_config.current.region

  lifecycle {
    ignore_changes = [
      location_id
    ]
  }
}

# scheduler
resource "google_cloud_scheduler_job" "certbot" {
  count       = var.certbot_cloud_function ? 1 : 0
  name        = "ztl-certbot"
  description = "Zentral certbot cloud function cron"
  schedule    = formatdate("m h * * *", timeadd(time_static.certbot_schedule_origin[0].rfc3339, "5m"))
  time_zone   = "Etc/UTC"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.certbot[0].id
    data       = base64encode("yolo")
  }

  depends_on = [
    google_app_engine_application.certbot
  ]
}

# certbot cloud function
resource "google_cloudfunctions_function" "certbot" {
  count       = var.certbot_cloud_function ? 1 : 0
  name        = "ztl-certbot"
  description = "Zentral certbot cloud function"
  runtime     = "python38"
  entry_point = "main"

  source_archive_bucket = var.certbot_source_archive_bucket
  source_archive_object = var.certbot_source_archive_object

  service_account_email = google_service_account.certbot[0].email
  available_memory_mb   = 256
  timeout               = 300
  max_instances         = 1
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.certbot[0].id
  }
}
