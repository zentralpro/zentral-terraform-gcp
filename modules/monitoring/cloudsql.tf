resource "google_monitoring_alert_policy" "cloudsql_cpu_utilization" {
  display_name          = "Zentral DB CPU utilization"
  combiner              = "OR"
  notification_channels = [for nc in google_monitoring_notification_channel.email : nc.id]

  conditions {
    display_name = "Zentral DB - CPU utilization"
    condition_threshold {
      filter = "resource.type = \"cloudsql_database\" AND metric.type = \"cloudsql.googleapis.com/database/cpu/utilization\""
      aggregations {
        alignment_period     = "1800s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.label.database_id"]
      }
      comparison      = "COMPARISON_GT"
      threshold_value = var.max_cloudsql_cpu_utilization_threshold / 100
      duration        = "0s"
      trigger {
        count = "1"
      }
    }
  }
}

resource "google_monitoring_alert_policy" "cloudsql_disk_utilization" {
  display_name          = "Zentral DB disk utilization"
  combiner              = "OR"
  notification_channels = [for nc in google_monitoring_notification_channel.email : nc.id]

  conditions {
    display_name = "Zentral DB - Disk utilization"
    condition_threshold {
      filter = "resource.type = \"cloudsql_database\" AND metric.type = \"cloudsql.googleapis.com/database/disk/utilization\""
      aggregations {
        alignment_period     = "1800s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.label.database_id"]
      }
      comparison      = "COMPARISON_GT"
      threshold_value = var.max_cloudsql_disk_utilization_threshold / 100
      duration        = "0s"
      trigger {
        count = "1"
      }
    }
  }
}

resource "google_monitoring_alert_policy" "cloudsql_memory_utilization" {
  display_name          = "Zentral DB memory utilization"
  combiner              = "OR"
  notification_channels = [for nc in google_monitoring_notification_channel.email : nc.id]

  conditions {
    display_name = "Zentral DB - Memory utilization"
    condition_threshold {
      filter = "resource.type = \"cloudsql_database\" AND metric.type = \"cloudsql.googleapis.com/database/memory/utilization\""
      aggregations {
        alignment_period     = "1800s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.label.database_id"]
      }
      comparison      = "COMPARISON_GT"
      threshold_value = var.max_cloudsql_memory_utilization_threshold / 100
      duration        = "0s"
      trigger {
        count = "1"
      }
    }
  }
}
