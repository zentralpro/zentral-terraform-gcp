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

output "terraform_service_account_email" {
  value = google_service_account.terraform.email
}

output "workload_identity_provider" {
  value = length(google_iam_workload_identity_pool_provider.github-actions) > 0 ? google_iam_workload_identity_pool_provider.github-actions[0].name : null
}
