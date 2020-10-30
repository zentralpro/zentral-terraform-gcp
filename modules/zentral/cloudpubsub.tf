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

resource "google_pubsub_topic" "events" {
  name = "ztl-events-topic"

  message_storage_policy {
    allowed_persistence_regions = [
      data.google_client_config.current.region,
    ]
  }
}

resource "google_pubsub_topic" "enriched_events" {
  name = "ztl-enriched-events-topic"

  message_storage_policy {
    allowed_persistence_regions = [
      data.google_client_config.current.region,
    ]
  }
}
