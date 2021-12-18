resource "google_monitoring_notification_channel" "email" {
  for_each     = toset(var.email_addresses)
  display_name = "${each.key} notification channel"
  type         = "email"
  labels = {
    email_address = each.key
  }
}
