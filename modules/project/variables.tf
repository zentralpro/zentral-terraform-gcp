variable "name" {
  description = "The project name"
}

variable "project_id" {
  type = string
}

variable "org_id" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "terraform_bucket_location" {
  default = "US"
}

variable "add_required_es_roles" {
  description = "Add the roles required for Elasticsearch to the service account. Defaults to true."
  default     = true
}

variable "github_repository" {
  description = "Name of the GitHub repository for the GitHub actions authentication"
  type        = string
  default     = null
}
