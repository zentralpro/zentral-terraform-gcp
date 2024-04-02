locals {
  workload_identity_count = (var.github_infra_repository != null || var.github_config_repository != null) ? 1 : 0
}

resource "google_iam_workload_identity_pool" "github-actions" {
  count = local.workload_identity_count

  project                   = var.project_id
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions"
  description               = "Identity pool for the GitHub actions"
}

resource "google_iam_workload_identity_pool_provider" "github-actions" {
  count = local.workload_identity_count

  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github-actions[0].workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  display_name                       = "GitHub Actions"
  description                        = "Identity pool provider for the GitHub actions"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  attribute_condition = join(
    " || ",
    compact([
      var.github_infra_repository != null ? "assertion.repository=='${var.github_infra_repository}'" : "",
      var.github_config_repository != null ? "assertion.repository=='${var.github_config_repository}'" : ""
    ])
  )
}

resource "google_service_account_iam_binding" "infra" {
  count = var.github_infra_repository != null ? 1 : 0

  service_account_id = google_service_account.terraform_infra.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github-actions[0].name}/attribute.repository/${var.github_infra_repository}"
  ]
}

resource "google_service_account_iam_binding" "config" {
  count = var.github_config_repository != null ? 1 : 0

  service_account_id = google_service_account.terraform_config[0].name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github-actions[0].name}/attribute.repository/${var.github_config_repository}"
  ]
}
