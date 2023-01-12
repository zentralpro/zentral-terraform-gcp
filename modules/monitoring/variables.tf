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

variable "min_vm_disk_free_space_threshold" {
  description = "Minimum VM disk free space, in %"
  default     = 15
}
