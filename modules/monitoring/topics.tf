resource "google_monitoring_alert_policy" "topics" {
  display_name          = "Zentral pub/sub topics failure"
  combiner              = "OR"
  notification_channels = [for nc in google_monitoring_notification_channel.email : nc.id]

  conditions {
    display_name = "Not enough events published to the Zentral topics"
    condition_threshold {
      filter = "metric.type=\"pubsub.googleapis.com/topic/send_message_operation_count\" AND resource.type=\"pubsub_topic\" AND resource.label.topic_id = has_substring(\"events\")"
      aggregations {
        alignment_period     = "600s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.label.topic_id"]
      }
      comparison      = "COMPARISON_LT"
      threshold_value = var.message_publication_rate_threshold
      duration        = "0s"
      trigger {
        count = "1"
      }
    }
  }
}
