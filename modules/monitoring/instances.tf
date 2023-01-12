resource "google_monitoring_alert_policy" "vm_disk_utilization" {
  display_name          = "Zentral VM disk utilization"
  combiner              = "OR"
  notification_channels = [for nc in google_monitoring_notification_channel.email : nc.id]

  conditions {
    display_name = "VM Instance - Disk utilization"
    condition_threshold {
      filter     = "resource.type = \"gce_instance\" AND metric.type = \"agent.googleapis.com/disk/percent_used\" AND (metric.labels.state = \"free\" AND metric.labels.device = \"/dev/sda1\")"
      duration   = "0s"
      comparison = "COMPARISON_LT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
      threshold_value = var.min_vm_disk_free_space_threshold
      trigger {
        count = "1"
      }
    }
  }
}
