variable "fqdn" {
  description = "FQDN of the Zentral web app"
  type        = string
}

variable "scheduled_api_calls" {
  description = "Scheduled Zentral API calls."
  type = map(object({
    path     = string
    token    = string
    schedule = string
  }))
  default = {}
}
