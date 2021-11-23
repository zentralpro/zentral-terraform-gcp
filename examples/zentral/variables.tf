variable "smtp_relay_password" {
  default   = "UNDEFINED"
  sensitive = true
}

variable "datadog_api_key" {
  default   = "UNDEFINED"
  sensitive = true
}

variable "splunk_hec_token" {
  default   = "UNDEFINED"
  sensitive = true
}

variable "splunk_api_token" {
  default = "UNDEFINED"
}

variable "splunk_api_cf_access_client_secret" {
  default = "UNDEFINED"
}

variable "geolite2_license_key" {
  default   = "UNDEFINED"
  sensitive = true
}

variable "crowdstrike_cid" {
  default   = "UNDEFINED"
  sensitive = true
}

#variable "cloudflare_api_token" {
#  type = string
#  sensitive = true
#}
