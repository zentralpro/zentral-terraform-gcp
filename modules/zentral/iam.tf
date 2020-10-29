#
# SA for ek instances with PK
#

# service account for the ek instances
resource "google_service_account" "ek" {
  account_id   = "ztl-ek-service-account"
  display_name = "Zentral ek service account"
  description  = "Service account for the zentral ek instances"
}

# the ek service account needs a private key for the elasticsearch repository
resource "google_service_account_key" "ek" {
  service_account_id = google_service_account.ek.name
}

#
# SA for web instances with PK
#

# service account for the web instances
resource "google_service_account" "web" {
  account_id   = "ztl-web-service-account"
  display_name = "Zentral web service account"
  description  = "Service account for the zentral web instances"
}

# the web service account needs a private key to sign gcs blob URLs
resource "google_service_account_key" "web" {
  service_account_id = google_service_account.web.name
}

#
# SA for worker instances with PK
#

# service account for the worker instances
resource "google_service_account" "worker" {
  account_id   = "ztl-worker-service-account"
  display_name = "Zentral worker service account"
  description  = "Service account for the zentral worker instances"
}

# the worker service account needs a private key to sign gcs blob URLs
resource "google_service_account_key" "worker" {
  service_account_id = google_service_account.worker.name
}

#
# Role for service discovery with bindings to ek, web, work SAs
#

# role with limited permissions for service discovery in the project
resource "google_project_iam_custom_role" "service-discovery" {
  role_id = "ztlServiceDiscovery"
  title   = "Zentral service discovery role"
  permissions = [
    "compute.instances.list",
    "storage.buckets.list",
    "cloudsql.instances.list",
    "redis.instances.list"
  ]
}

# bind the role to the instance service accounts
resource "google_project_iam_binding" "project" {
  role = google_project_iam_custom_role.service-discovery.id

  members = [
    "serviceAccount:${google_service_account.ek.email}",
    "serviceAccount:${google_service_account.web.email}",
    "serviceAccount:${google_service_account.worker.email}"
  ]
}
