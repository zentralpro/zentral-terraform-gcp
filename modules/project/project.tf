# the project

resource "google_project" "this" {
  name                = var.name
  project_id          = var.project_id
  org_id              = var.org_id
  billing_account     = var.billing_account
  auto_create_network = false
}

# service account for terraform

resource "google_service_account" "terraform" {
  project      = google_project.this.project_id
  account_id   = "terraform"
  display_name = "Terraform"
  description  = "Service account for the Zentral terraform deployment"
}

resource "google_project_iam_member" "terraform" {
  for_each = toset([
    "roles/serviceusage.serviceUsageAdmin",
    "roles/iam.roleAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/iam.securityAdmin",
    "roles/compute.admin",
    "roles/servicenetworking.networksAdmin",
    "roles/pubsub.admin",
    "roles/redis.admin",
    "roles/secretmanager.admin",
    "roles/cloudsql.admin",
    "roles/storage.admin",
    "roles/appengine.appAdmin",
    "roles/appengine.appCreator",
    "roles/cloudscheduler.admin",
    "roles/cloudfunctions.developer"
  ])
  project = google_project.this.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

# storage bucket for the terraform state

resource "google_storage_bucket" "terraform" {
  project                     = google_project.this.project_id
  name                        = "${var.project_id}-terraform"
  location                    = var.terraform_bucket_location
  uniform_bucket_level_access = true
}

# the service usage API needs to be activated from outside the project
# to allow the service account to activate the other ones

resource "google_project_service" "service" {
  project            = google_project.this.project_id
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
}
