# see https://cloud.google.com/monitoring/alerts/policies-in-json#json-uptime

resource "google_monitoring_uptime_check_config" "fqdn" {
  display_name = "Zentral uptime check"
  timeout      = "10s"
  period       = "300s"

  http_check {
    request_method = "GET"
    path           = "/health_check/"
    port           = "443"
    use_ssl        = true
    validate_ssl   = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = data.google_client_config.current.project
      host       = var.fqdn
    }
  }

  content_matchers {
    matcher = "CONTAINS_STRING"
    content = "OK"
  }
}

resource "google_monitoring_alert_policy" "uptime_check" {
  display_name          = "Zentral uptime check failure"
  combiner              = "OR"
  notification_channels = [for nc in google_monitoring_notification_channel.email : nc.id]

  conditions {
    display_name = "Zentral down"
    condition_threshold {
      filter     = format("metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\" AND metric.label.\"check_id\"=\"%s\"", google_monitoring_uptime_check_config.fqdn.uptime_check_id)
      duration   = "600s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period     = "1200s"
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields      = ["resource.label.*"]
      }
      threshold_value = "1"
      trigger {
        count = "1"
      }
    }
  }

  conditions {
    display_name = "Zentral SSL certificate expiring soon"
    condition_threshold {
      filter     = format("metric.type=\"monitoring.googleapis.com/uptime_check/time_until_ssl_cert_expires\" AND resource.type=\"uptime_url\" AND metric.label.\"check_id\"=\"%s\"", google_monitoring_uptime_check_config.fqdn.uptime_check_id)
      duration   = "600s"
      comparison = "COMPARISON_LT"
      aggregations {
        alignment_period     = "1200s"
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = ["resource.label.*"]
      }
      threshold_value = "15"
      trigger {
        count = "1"
      }
    }
  }
}
