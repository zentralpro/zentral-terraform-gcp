# Google project ID
variable "project_id" {
  type = string
}

# default Google region
variable "region" {
  default = "us-east1"
}

# default Google zone
variable "default_zone" {
  default = "us-east1-c"
}

# vpc network id
variable "network_id" {
  type = string
}

# vpc network name
variable "network_name" {
  type = string
}

# web instances managed instance group target size
variable "web_mig_target_size" {
  default = 2
}

# worker instances managed instance group target size
variable "worker_mig_target_size" {
  default = 1
}

# project metadata used during setup

variable "admin_email" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "fqdn" {
  type = string
}

variable "fqdn_mtls" {
  default = "UNDEFINED"
}

variable "tls_cachain" {
  default = "UNDEFINED"
}

variable "distribute_tls_server_certs" {
  default = "0"
}

variable "geolite2_account_id" {
  default = "UNDEFINED"
}

variable "geolite2_license_key" {
  default = "UNDEFINED"
}

variable "base_json" {
  type = string
}

# datadog configuration

variable "datadog_api_key" {
  default = "UNDEFINED"
}

variable "datadog_site" {
  default = "UNDEFINED"
}

# instances

variable "web_machine_type" {
  default = "custom-1-1024"
}

variable "worker_machine_type" {
  default = "custom-1-1024"
}

variable "ek_machine_type" {
  default = "custom-1-5120"
}

# smtp

variable "default_from_email" {
  default = "UNDEFINED"
}

variable "smtp_relay_host" {
  default = "UNDEFINED"
}

variable "smtp_relay_user" {
  default = "UNDEFINED"
}

variable "smtp_relay_password" {
  default = "UNDEFINED"
}

# DANGER - ONLY FOR TESTS!!!
variable "destroy_all_resources" {
  description = "Set to true during testing to remove the db deletion protection and allow non-empty bucket deletion"
  default     = false
}
