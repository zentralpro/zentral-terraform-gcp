variable "registration_email" {
  description = "The email address to use for the ACME registration"
  type        = string
}

variable "fqdns" {
  description = "The list of FQDN for the certificate"
  type        = list(string)
}

variable "project_id" {
  description = "The GCP project ID for the DNS challenge"
  type        = string
}
