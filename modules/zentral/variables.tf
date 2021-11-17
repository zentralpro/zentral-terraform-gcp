# vpc network id
variable "network_id" {
  type = string
}

# vpc subnetwork name
variable "subnetwork_name" {
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

variable "tls_cert" {
  default = "UNDEFINED"
}

variable "tls_chain" {
  default = "UNDEFINED"
}

variable "tls_privkey" {
  default = "UNDEFINED"
}

variable "tls_cachain" {
  default = "UNDEFINED"
}

variable "distribute_tls_server_certs" {
  default = "0"
}

# http://nginx.org/en/docs/http/ngx_http_realip_module.html
variable "set_real_ip_from" {
  description = "Nginx realip module. List of trusted addresses that are known to send correct replacement addresses."
  type        = list(string)
  default     = []
}

# http://nginx.org/en/docs/http/ngx_http_realip_module.html
variable "real_ip_header" {
  description = "Nginx realip module. Request header field whose value will be used to replace the client address."
  default     = "UNDEFINED"
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

variable "datadog_site" {
  default = "datadoghq.com"
}

variable "datadog_service" {
  default = "Zentral"
}

variable "datadog_api_key" {
  default = "UNDEFINED"
}

# splunk

variable "splunk_hec_token" {
  default = "UNDEFINED"
}


# instances

variable "images_project" {
  description = "The ID of the project from which the images are distributed"
  default     = "sublime-delight-encoder"
}

variable "web_image" {
  default = "LATEST"
}

variable "web_machine_type" {
  default = "custom-1-1024"
}

variable "worker_image" {
  default = "LATEST"
}

variable "worker_machine_type" {
  default = "custom-1-1024"
}

variable "ek_image" {
  default = "LATEST"
}

variable "ek_machine_type" {
  default = "custom-1-5120"
}

variable "ek_data_disk_size" {
  default = 30
}

variable "db_tier" {
  default = "db-custom-1-3840"
}

variable "monitoring_image" {
  default = "LATEST"
}

variable "monitoring_machine_type" {
  default = "custom-1-1024"
}

# DB backup

variable "db_backup_enabled" {
  default = false
}

variable "db_backup_start_time" {
  default     = "00:00"
  description = "Beginning (24-hour time, UTC) of a 4-hour backup window"
}

variable "db_backup_count" {
  default = 7
}

variable "db_point_in_time_recovery_enabled" {
  default = false
}

variable "db_transaction_log_retention_days" {
  default = 7
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

variable "smtp_allowed_recipient_domains" {
  default = []
  type    = list(string)
}

# CrowdStrike

variable "crowdstrike_cid" {
  description = "CrowdStrike Customer ID Checksum for the Falcon Agent"
  default     = "UNDEFINED"
}

variable "crowdstrike_deb" {
  description = "Filename (Key) of the CrowdStrike Falcon Agent deb installer package on the dist bucket"
  default     = "UNDEFINED"
}

# Certbot cloud function

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  default     = "UNDEFINED"
}

variable "certbot_cloud_function" {
  description = "Enable certbot cloud function"
  default     = false
}

# DANGER - ONLY FOR TESTS!!!
variable "destroy_all_resources" {
  description = "Set to true during testing to remove the db deletion protection and allow non-empty bucket deletion"
  default     = false
}
