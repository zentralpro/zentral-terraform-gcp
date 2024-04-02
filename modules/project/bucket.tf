# storage bucket for the terraform state

resource "google_storage_bucket" "terraform" {
  project                     = google_project.this.project_id
  name                        = "${var.project_id}-terraform"
  location                    = var.terraform_bucket_location
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "terraform_config_ro" {
  count = length(google_service_account.terraform_config) > 0 ? 1 : 0

  bucket = google_storage_bucket.terraform.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.terraform_config[0].email}"

  condition {
    title       = "Not the infra subfolder"
    description = "Block access to the infra/ subfolder"
    expression  = "!resource.name.startsWith('projects/_/buckets/${google_storage_bucket.terraform.name}/objects/infra/')"
  }
}

resource "google_storage_bucket_iam_member" "terraform_config_rw" {
  count = length(google_service_account.terraform_config) > 0 ? 1 : 0

  bucket = google_storage_bucket.terraform.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.terraform_config[0].email}"

  condition {
    title       = "Only config subfolder"
    description = "Objects in the config/ subfolder"
    expression  = "resource.name.startsWith('projects/_/buckets/${google_storage_bucket.terraform.name}/objects/config/')"
  }
}
