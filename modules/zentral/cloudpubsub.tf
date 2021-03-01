resource "google_project_iam_member" "web_cloud_pubsub" {
  role   = "roles/pubsub.editor"
  member = "serviceAccount:${google_service_account.web.email}"
}

resource "google_project_iam_member" "worker_cloud_pubsub" {
  role   = "roles/pubsub.editor"
  member = "serviceAccount:${google_service_account.worker.email}"
}

resource "google_pubsub_topic" "raw_events" {
  name = "ztl-raw-events-topic"

  message_storage_policy {
    allowed_persistence_regions = [
      data.google_client_config.current.region,
    ]
  }
}

resource "google_pubsub_subscription" "raw_events" {
  name  = "raw-events-subscription"
  topic = google_pubsub_topic.raw_events.name
}

resource "google_pubsub_topic" "events" {
  name = "ztl-events-topic"

  message_storage_policy {
    allowed_persistence_regions = [
      data.google_client_config.current.region,
    ]
  }
}

resource "google_pubsub_subscription" "events" {
  name  = "events-subscription"
  topic = google_pubsub_topic.events.name
}

resource "google_pubsub_topic" "enriched_events" {
  name = "ztl-enriched-events-topic"

  message_storage_policy {
    allowed_persistence_regions = [
      data.google_client_config.current.region,
    ]
  }
}

resource "google_pubsub_subscription" "process_enriched_events" {
  name  = "process-enriched-events-subscription"
  topic = google_pubsub_topic.enriched_events.name
}

resource "google_pubsub_subscription" "elasticsearch" {
  name  = "elasticsearch-store-enriched-events-subscription"
  topic = google_pubsub_topic.enriched_events.name
}

resource "google_pubsub_subscription" "datadog" {
  count = var.datadog_api_key == "UNDEFINED" ? 0 : 1
  name  = "datadog-store-enriched-events-subscription"
  topic = google_pubsub_topic.enriched_events.name
}
