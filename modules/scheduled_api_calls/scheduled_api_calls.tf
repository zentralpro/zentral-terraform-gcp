locals {
  scheduled_api_call_keys = toset([for k, v in var.scheduled_api_calls : k])
}

resource "google_cloud_scheduler_job" "scheduled_api_calls" {
  for_each = local.scheduled_api_call_keys

  name             = "zentral-${each.key}"
  schedule         = var.scheduled_api_calls[each.key]["schedule"]
  description      = lookup(var.scheduled_api_calls[each.key], "description", each.key)
  attempt_deadline = "30s"

  retry_config {
    retry_count = 1
  }

  http_target {
    uri         = format("https://%s%s", var.fqdn, var.scheduled_api_calls[each.key]["path"])
    http_method = "POST"
    headers = {
      Authorization = format("Token %s", var.scheduled_api_calls[each.key]["token"])
    }
  }
}
