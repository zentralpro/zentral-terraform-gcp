output "id" {
  value       = google_project.this.project_id
  description = "The project id"
}

output "name" {
  value       = google_project.this.name
  description = "The project name"
}

output "number" {
  value       = google_project.this.number
  description = "The project number"
}

output "workload_identity_provider" {
  value = length(google_iam_workload_identity_pool_provider.github-actions) > 0 ? google_iam_workload_identity_pool_provider.github-actions[0].name : null
}

output "terraform_infra_service_account_email" {
  value = google_service_account.terraform_infra.email
}

output "terraform_config_service_account_email" {
  value = length(google_service_account.terraform_config) > 0 ? google_service_account.terraform_config[0].email : null
}
