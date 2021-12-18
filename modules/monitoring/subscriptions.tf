resource "google_monitoring_alert_policy" "subscriptions" {
  display_name          = "Zentral pub/sub subscriptions failure"
  combiner              = "OR"
  notification_channels = [for nc in google_monitoring_notification_channel.email : nc.id]

  conditions {
    display_name = "Zentral subscription filling up"
    condition_threshold {
      filter     = "metric.type=\"pubsub.googleapis.com/subscription/num_undelivered_messages\" AND resource.type=\"pubsub_subscription\" AND resource.label.subscription_id = ends_with(\"-subscription\")"
      duration   = "600s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
        group_by_fields    = ["resource.label.subscription_id"]
      }
      threshold_value = var.undelivered_messages_threshold
      trigger {
        count = "1"
      }
    }
  }

  conditions {
    display_name = "Zentral subscription oldest message too old"
    condition_threshold {
      filter     = "metric.type=\"pubsub.googleapis.com/subscription/oldest_unacked_message_age\" AND resource.type=\"pubsub_subscription\" AND resource.label.subscription_id = ends_with(\"-subscription\")"
      duration   = "600s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
        group_by_fields    = ["resource.label.subscription_id"]
      }
      threshold_value = var.oldest_unacked_message_threshold
      trigger {
        count = "1"
      }
    }
  }
}
