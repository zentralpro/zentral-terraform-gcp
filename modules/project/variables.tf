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
