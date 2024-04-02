# service account for terraform / infra

resource "google_service_account" "terraform_infra" {
  project      = google_project.this.project_id
  account_id   = "terraform-infra"
  display_name = "Terraform Infra"
  description  = "Service account for the Zentral infrastructure terraform deployment"
}

moved {
  from = google_service_account.terraform
  to   = google_service_account.terraform_infra
}

resource "google_project_iam_member" "terraform_infra" {
  for_each = toset([
    "roles/serviceusage.serviceUsageAdmin",
    "roles/iam.roleAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/resourcemanager.projectIamAdmin",
    "roles/compute.admin",
    "roles/servicenetworking.networksAdmin",
    "roles/pubsub.admin",
    "roles/redis.admin",
    "roles/secretmanager.admin",
    "roles/cloudsql.admin",
    "roles/storage.admin",
    "roles/cloudkms.admin",
    # cloud function
    "roles/appengine.appAdmin",
    "roles/appengine.appCreator",
    "roles/cloudscheduler.admin",
    "roles/cloudfunctions.developer",
    # monitoring
    "roles/monitoring.alertPolicyEditor",
    "roles/monitoring.notificationChannelEditor",
    "roles/monitoring.uptimeCheckConfigEditor",
  ])
  project = google_project.this.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.terraform_infra.email}"
}

moved {
  from = google_project_iam_member.terraform
  to   = google_project_iam_member.terraform_infra
}

resource "google_project_iam_member" "terraform_es" {
  count   = var.add_required_es_roles ? 1 : 0
  project = google_project.this.project_id
  role    = "roles/iam.serviceAccountKeyAdmin"
  member  = "serviceAccount:${google_service_account.terraform_infra.email}"
}

# service account for terraform / config

resource "google_service_account" "terraform_config" {
  count = var.github_config_repository != null ? 1 : 0

  project      = google_project.this.project_id
  account_id   = "terraform-config"
  display_name = "Terraform Config"
  description  = "Service account for the Zentral configuration terraform deployment"
}
