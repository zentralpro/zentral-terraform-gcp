resource "google_monitoring_notification_channel" "email" {
  display_name = "Zentral email notification channel"
  type         = "email"
  labels = {
    email_address = var.admin_email
  }
}

resource "google_monitoring_alert_policy" "elasticsearch_subscription" {
  combiner     = "OR"
  display_name = "Elasticsearch subscription alert"
  documentation {
    content   = "The **Elasticsearch** pub/sub subscription is filling up. Check the elasticsearch store worker(s) and elasticsearch itself."
    mime_type = "text/markdown"
  }
  notification_channels = [google_monitoring_notification_channel.email.id]
  conditions {
    display_name = "More than 1000 unacked events over 1 min"
    condition_threshold {
      filter          = "resource.type=\"pubsub_subscription\" metric.type=\"pubsub.googleapis.com/subscription/num_undelivered_messages\" AND resource.label.\"subscription_id\"=\"elasticsearch-store-enriched-events-subscription\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1000
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
}
