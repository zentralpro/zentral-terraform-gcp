#
# SA for ek instances with PK
#

# service account for the ek instances
resource "google_service_account" "ek" {
  count        = var.ek_instance_count > 0 ? 1 : 0
  account_id   = "ztl-ek-service-account"
  display_name = "Zentral ek service account"
  description  = "Service account for the zentral ek instances"
}

# the ek service account needs a private key for the elasticsearch repository
resource "google_service_account_key" "ek" {
  count              = var.ek_instance_count > 0 ? 1 : 0
  service_account_id = google_service_account.ek[0].name
}

#
# SA for monitoring instance
#

# service account for the monitoring instances
resource "google_service_account" "monitoring" {
  account_id   = "ztl-monitoring-service-account"
  display_name = "Zentral monitoring service account"
  description  = "Service account for the zentral monitoring instance"
}

#
# SA for Vault instance
#

# service account for the Vault instances
resource "google_service_account" "vault" {
  count = var.vault_instance_count > 0 ? 1 : 0

  account_id   = "ztl-vault-service-account"
  display_name = "Zentral Vault service account"
  description  = "Service account for the zentral Vault instance"
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

#
# SA for worker instances with PK
#

# service account for the worker instances
resource "google_service_account" "worker" {
  account_id   = "ztl-worker-service-account"
  display_name = "Zentral worker service account"
  description  = "Service account for the zentral worker instances"
}

#
# Role for service discovery with bindings to ek, monitoring, vault, web, work SAs
#

# role with limited permissions for service discovery in the project
resource "google_project_iam_custom_role" "service-discovery" {
  role_id = "ztlServiceDiscovery"
  title   = "Zentral service discovery role"
  permissions = [
    "compute.instances.list",
    "compute.zones.list",
    "storage.buckets.list",
    "cloudsql.instances.list",
    "redis.instances.list"
  ]
}

# bind the role to the instance service accounts
resource "google_project_iam_binding" "project" {
  role = google_project_iam_custom_role.service-discovery.id

  members = compact([
    var.ek_instance_count > 0 ? "serviceAccount:${google_service_account.ek[0].email}" : "",
    "serviceAccount:${google_service_account.monitoring.email}",
    var.vault_instance_count > 0 ? "serviceAccount:${google_service_account.vault[0].email}" : "",
    "serviceAccount:${google_service_account.web.email}",
    "serviceAccount:${google_service_account.worker.email}"
  ])
}

# role with signBlob permission for signing GCS blob URLs
resource "google_project_iam_custom_role" "gcs_signing" {
  role_id = "ztlGCSSigning"
  title   = "Zentral GCS signing role"
  permissions = [
    "iam.serviceAccounts.signBlob"
  ]
}

# allow the web SA to sign blobs with its own ID
resource "google_service_account_iam_binding" "web_gcs_signing" {
  service_account_id = google_service_account.web.name
  role               = google_project_iam_custom_role.gcs_signing.id
  members = [
    "serviceAccount:${google_service_account.web.email}"
  ]
}

# allow the worker SA to sign blobs with its own ID
resource "google_service_account_iam_binding" "worker_gcs_signing" {
  service_account_id = google_service_account.worker.name
  role               = google_project_iam_custom_role.gcs_signing.id
  members = [
    "serviceAccount:${google_service_account.worker.email}"
  ]
}

# find the logging.logWriter role
data "google_iam_role" "log-writer" {
  name = "roles/logging.logWriter"
}

# assign logging.logWriter role to the service accounts who need it
resource "google_project_iam_binding" "logging" {
  count = var.datadog_api_key == "UNDEFINED" ? 1 : 0
  role  = data.google_iam_role.log-writer.id

  members = compact([
    var.ek_instance_count > 0 ? "serviceAccount:${google_service_account.ek[0].email}" : "",
    "serviceAccount:${google_service_account.monitoring.email}",
    var.vault_instance_count > 0 ? "serviceAccount:${google_service_account.vault[0].email}" : "",
    "serviceAccount:${google_service_account.web.email}",
    "serviceAccount:${google_service_account.worker.email}"
  ])
}

# find the monitoring.metricWriter role
data "google_iam_role" "metric-writer" {
  name = "roles/monitoring.metricWriter"
}

# assign monitoring.metricWriter role to the service accounts who need it
resource "google_project_iam_binding" "monitoring" {
  count = var.datadog_api_key == "UNDEFINED" ? 1 : 0
  role  = data.google_iam_role.metric-writer.id

  members = compact([
    var.ek_instance_count > 0 ? "serviceAccount:${google_service_account.ek[0].email}" : "",
    "serviceAccount:${google_service_account.monitoring.email}",
    var.vault_instance_count > 0 ? "serviceAccount:${google_service_account.vault[0].email}" : "",
    "serviceAccount:${google_service_account.web.email}",
    "serviceAccount:${google_service_account.worker.email}"
  ])
}

# find the monitoring.viewer role
data "google_iam_role" "monitoring-viewer" {
  name = "roles/monitoring.viewer"
}

# assign monitoring.viewer role to the service accounts who need it
resource "google_project_iam_binding" "monitoring-viewer" {
  count = var.datadog_api_key == "UNDEFINED" ? 1 : 0
  role  = data.google_iam_role.monitoring-viewer.id

  members = [
    "serviceAccount:${google_service_account.monitoring.email}",
  ]
}

# find the logging.viewAccessor role
# for the grafana googlecloud logging datasource
data "google_iam_role" "logging-view-accessor" {
  name = "roles/logging.viewAccessor"
}

# assign monitoring.viewer role to the service accounts who need it
resource "google_project_iam_binding" "logging-view-accessor" {
  count = var.datadog_api_key == "UNDEFINED" ? 1 : 0
  role  = data.google_iam_role.logging-view-accessor.id

  members = [
    "serviceAccount:${google_service_account.monitoring.email}",
  ]
}

# find the logging.viewAccessor role
# for the grafana googlecloud logging datasource
data "google_iam_role" "logging-viewer" {
  name = "roles/logging.viewer"
}

# assign monitoring.viewer role to the service accounts who need it
resource "google_project_iam_binding" "logging-viewer" {
  count = var.datadog_api_key == "UNDEFINED" ? 1 : 0
  role  = data.google_iam_role.logging-viewer.id

  members = [
    "serviceAccount:${google_service_account.monitoring.email}",
  ]
}

# find the cloudsql.client role
data "google_iam_role" "cloudsql-client" {
  name = "roles/cloudsql.client"
}

# assign cloudsql.client role to the service accounts who need it
resource "google_project_iam_binding" "cloudsql-client" {
  role = data.google_iam_role.cloudsql-client.id

  members = [
    "serviceAccount:${google_service_account.web.email}",
    "serviceAccount:${google_service_account.worker.email}"
  ]
}

# role with limited permissions for the GCE Vault authentication and the project metadata updates (CA chains)
resource "google_project_iam_custom_role" "vault" {
  count = var.vault_instance_count > 0 ? 1 : 0

  role_id = "ztlVault"
  title   = "Zentral role to allow the Vault instance to verify GCE auth"
  permissions = [
    "compute.instances.get",                      # For the GCE auth
    "iam.serviceAccounts.get",                    # For the GCE auth
    "compute.projects.get",                       # For ztl_admin / vault / auto_cachain
    "compute.projects.setCommonInstanceMetadata", # For ztl_admin / vault / auto_cachain
    "iam.serviceAccounts.actAs",                  # For ztl_admin / vault / auto_cachain
    "compute.globalOperations.get",               # For ztl_admin / vault / auto_cachain
  ]
}

# bind the role to the vault instance service account
resource "google_project_iam_binding" "vault" {
  count = var.vault_instance_count > 0 ? 1 : 0

  role = google_project_iam_custom_role.vault[0].id
  members = [
    "serviceAccount:${google_service_account.vault[0].email}"
  ]
}
