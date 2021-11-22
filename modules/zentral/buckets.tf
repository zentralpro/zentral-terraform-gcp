#
# Zentral
#

# bucket for the zentral app django file storage
resource "google_storage_bucket" "zentral" {
  name = "ztl-zentral-${data.google_client_config.current.project}"
  labels = {
    usage = "zentral"
  }
  location                    = data.google_client_config.current.region
  storage_class               = "REGIONAL"
  uniform_bucket_level_access = true
  force_destroy               = var.destroy_all_resources
}

# allow the web service account RW access to the zentral bucket
resource "google_storage_bucket_iam_member" "zentral-bucket-web-service-account-access" {
  bucket = google_storage_bucket.zentral.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.web.email}"
}

# allow the worker service account RW access to the zentral bucket
resource "google_storage_bucket_iam_member" "zentral-bucket-worker-service-account-access" {
  bucket = google_storage_bucket.zentral.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.worker.email}"
}

#
# Elasticsearch
#

# bucket for the elasticsearch backups
resource "google_storage_bucket" "elastic" {
  count = var.ek_instance_count > 0 ? 1 : 0
  name  = "ztl-elastic-${data.google_client_config.current.project}"
  labels = {
    usage = "elastic"
  }
  location                    = data.google_client_config.current.region
  storage_class               = "REGIONAL"
  uniform_bucket_level_access = true
  force_destroy               = var.destroy_all_resources
}

# allow the ek service account RW access to the elactic bucket
resource "google_storage_bucket_iam_member" "elastic-bucket-service-account" {
  count  = var.ek_instance_count > 0 ? 1 : 0
  bucket = google_storage_bucket.elastic[0].name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.ek[0].email}"
}

#
# dist
#

# bucket for the distribution of extra software
resource "google_storage_bucket" "dist" {
  name = "ztl-dist-${data.google_client_config.current.project}"
  labels = {
    usage = "dist"
  }
  location                    = data.google_client_config.current.region
  storage_class               = "REGIONAL"
  uniform_bucket_level_access = true
  force_destroy               = var.destroy_all_resources
}

# allow the ek service account R access to the dist bucket
resource "google_storage_bucket_iam_member" "dist-bucket-ek-service-account" {
  count  = var.ek_instance_count > 0 ? 1 : 0
  name   = "ztl-elastic-${data.google_client_config.current.project}"
  bucket = google_storage_bucket.dist.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.ek[0].email}"
}

# allow the monitoring service account R access to the dist bucket
resource "google_storage_bucket_iam_member" "dist-bucket-monitoring-service-account" {
  bucket = google_storage_bucket.dist.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.monitoring.email}"
}

# allow the web service account R access to the dist bucket
resource "google_storage_bucket_iam_member" "dist-bucket-web-service-account-access" {
  bucket = google_storage_bucket.dist.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.web.email}"
}

# allow the worker service account R access to the zentral bucket
resource "google_storage_bucket_iam_member" "dist-bucket-worker-service-account-access" {
  bucket = google_storage_bucket.dist.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.worker.email}"
}
