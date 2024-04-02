# the project

resource "google_project" "this" {
  name                = var.name
  project_id          = var.project_id
  org_id              = var.org_id
  billing_account     = var.billing_account
  auto_create_network = false

  lifecycle {
    ignore_changes = [
      org_id,
      folder_id,
      billing_account,
      auto_create_network
    ]
  }
}

resource "google_project_service" "service_usage" {
  project            = google_project.this.project_id
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam_credentials" {
  project            = google_project.this.project_id
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}
