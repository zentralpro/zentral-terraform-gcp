# create custom role to give the compute.instances.setMetadata
# permission to the external admins, for the SSH key
resource "google_project_iam_custom_role" "set_instance_metadata" {
  role_id     = "ztlSetInstanceMetadata"
  title       = "Zentral set instance metadata (for SSH)"
  permissions = ["compute.instances.setMetadata"]
}

# add each external admin to the set instance metadata role
resource "google_project_iam_member" "external_admin_set_instance_metadata" {
  for_each = toset(var.external_admins)
  role     = google_project_iam_custom_role.set_instance_metadata.id
  member   = "user:${each.key}"
}

# add each external admin to the compute viewer role
resource "google_project_iam_member" "external_admin_compute_viewer" {
  for_each = toset(var.external_admins)
  role     = "roles/compute.viewer"
  member   = "user:${each.key}"
}

# add each external admin to the IAP-Secured Tunnel User
resource "google_project_iam_member" "external_admin_iap_secured_tunnel_user" {
  for_each = toset(var.external_admins)
  role     = "roles/iap.tunnelResourceAccessor"
  member   = "user:${each.key}"
}

# add each external admin as users of the zentral instances service accounts
resource "google_service_account_iam_member" "external_admin_web" {
  for_each           = toset(var.external_admins)
  service_account_id = google_service_account.web.name
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${each.key}"
}

resource "google_service_account_iam_member" "external_admin_worker" {
  for_each           = toset(var.external_admins)
  service_account_id = google_service_account.worker.name
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${each.key}"
}

resource "google_service_account_iam_member" "external_admin_monitoring" {
  for_each           = toset(var.external_admins)
  service_account_id = google_service_account.monitoring.name
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${each.key}"
}

resource "google_service_account_iam_member" "external_admin_ek" {
  for_each           = var.ek_instance_count > 0 ? toset(var.external_admins) : toset([])
  service_account_id = google_service_account.ek[0].name
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${each.key}"
}

# add each external admin to the logs view accessor role
resource "google_project_iam_member" "external_admin_logs_view_accessor" {
  for_each = toset(var.external_admins)
  role     = "roles/logging.viewAccessor"
  member   = "user:${each.key}"
}
