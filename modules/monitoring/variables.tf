variable "email_addresses" {
  description = "List of email addresses to notify"
  default     = []
  type        = list(string)
}

variable "fqdn" {
  type = string
}

variable "undelivered_messages_threshold" {
  description = "Subscriptions undelivered messages alarm threshold"
  default     = 5000
}

variable "oldest_unacked_message_threshold" {
  description = "Subscriptions oldest unacked message alarm threshold, in seconds"
  default     = 3600
}

variable "message_publication_rate_threshold" {
  description = "Minimum rate of message publication, in messages/second"
  default     = 0.1
}

variable "min_vm_disk_free_space_threshold" {
  description = "Minimum VM disk free space, in %"
  default     = 15
}

variable "max_cloudsql_cpu_utilization_threshold" {
  description = "Max CloudSQL CPU utilization, in %"
  default     = 80
}

variable "max_cloudsql_disk_utilization_threshold" {
  description = "Max CloudSQL disk utilization, in %"
  default     = 80
}

variable "max_cloudsql_memory_utilization_threshold" {
  description = "Max CloudSQL memory utilization, in %"
  default     = 80
}
