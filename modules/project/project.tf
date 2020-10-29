resource "random_pet" "project_id_suffix" {
  length = 3
}

resource "google_project" "this" {
  name                = var.name
  project_id          = random_pet.project_id_suffix.id
  org_id              = var.org_id
  billing_account     = var.billing_account
  auto_create_network = false
}

resource "google_project_service" "service" {
  for_each = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
    "pubsub.googleapis.com",
    "redis.googleapis.com",
  ])

  service = each.key

  project            = google_project.this.project_id
  disable_on_destroy = false
}
