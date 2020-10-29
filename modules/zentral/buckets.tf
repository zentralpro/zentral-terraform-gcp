#
# Zentral
#

# bucket for the zentral app django file storage
resource "google_storage_bucket" "zentral" {
  name = "ztl-zentral-${var.project_id}"
  labels = {
    usage = "zentral"
  }
  location                    = var.region
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
  name = "ztl-elastic-${var.project_id}"
  labels = {
    usage = "elastic"
  }
  location                    = var.region
  storage_class               = "REGIONAL"
  uniform_bucket_level_access = true
  force_destroy               = var.destroy_all_resources
}

# allow the ek service account RW access to the elactic bucket
resource "google_storage_bucket_iam_member" "elastic-bucket-service-account" {
  bucket = google_storage_bucket.elastic.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.ek.email}"
}
