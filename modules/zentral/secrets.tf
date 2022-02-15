#
# tls privkey
#

# tls privkey secret
resource "google_secret_manager_secret" "tls_privkey" {
  secret_id = "ztl-tls-privkey"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# tls privkey read access for web service account
resource "google_secret_manager_secret_iam_member" "tls_privkey" {
  secret_id = google_secret_manager_secret.tls_privkey.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# tls_privkey value or placeholder
resource "google_secret_manager_secret_version" "tls_privkey" {
  secret      = google_secret_manager_secret.tls_privkey.id
  secret_data = var.tls_privkey

  # not managed by tf
  lifecycle {
    ignore_changes = [
      secret_data
    ]
  }
}

#
# db_password: zentral user password for postgres db
#

# db_password secret
resource "google_secret_manager_secret" "db_password" {
  secret_id = "ztl-db-password"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# db_password read access for web service account
resource "google_secret_manager_secret_iam_member" "db_password_web" {
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# db_password read access for worker service account
resource "google_secret_manager_secret_iam_member" "db_password_worker" {
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.worker.email}"
}

# db_password value
resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db.result
}

#
# api_secret: zentral API secret for base.json
#

# generate
resource "random_password" "api_secret" {
  length = 71
}

# api_secret secret
resource "google_secret_manager_secret" "api_secret" {
  secret_id = "ztl-api-secret"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# api_secret read access for web service account
resource "google_secret_manager_secret_iam_member" "api_secret_web" {
  secret_id = google_secret_manager_secret.api_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# api_secret read access for worker service account
resource "google_secret_manager_secret_iam_member" "api_secret_worker" {
  secret_id = google_secret_manager_secret.api_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.worker.email}"
}

# api_secret value
resource "google_secret_manager_secret_version" "api_secret" {
  secret      = google_secret_manager_secret.api_secret.id
  secret_data = random_password.api_secret.result
}

#
# django_secret_key: zentral django app secret key
#

# generate
resource "random_password" "django_secret_key" {
  length = 71
}

# django_secret_key secret
resource "google_secret_manager_secret" "django_secret_key" {
  secret_id = "ztl-django-secret-key"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# django_secret_key read access for web service account
resource "google_secret_manager_secret_iam_member" "django_secret_key_web" {
  secret_id = google_secret_manager_secret.django_secret_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# django_secret_key read access for worker service account
resource "google_secret_manager_secret_iam_member" "django_secret_key_worker" {
  secret_id = google_secret_manager_secret.django_secret_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.worker.email}"
}

# django_secret_key value
resource "google_secret_manager_secret_version" "django_secret_key" {
  secret      = google_secret_manager_secret.django_secret_key.id
  secret_data = random_password.django_secret_key.result
}

#
# metrics_bearer_token: bearer token used to authenticate the prometheus requests
#

# generate
resource "random_password" "metrics_bearer_token" {
  length = 37
}

# metrics_bearer_token secret
resource "google_secret_manager_secret" "metrics_bearer_token" {
  secret_id = "ztl-metrics-bearer-token"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# metrics_bearer_token read access for web service account
resource "google_secret_manager_secret_iam_member" "metrics_bearer_token_web" {
  secret_id = google_secret_manager_secret.metrics_bearer_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# metrics_bearer_token read access for monitoring service account
resource "google_secret_manager_secret_iam_member" "metrics_bearer_token_monitoring" {
  secret_id = google_secret_manager_secret.metrics_bearer_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.monitoring.email}"
}

# metrics_bearer_token value
resource "google_secret_manager_secret_version" "metrics_bearer_token" {
  secret      = google_secret_manager_secret.metrics_bearer_token.id
  secret_data = random_password.metrics_bearer_token.result
}

#
# web_private_key: private key for the web service account
# needed to be able to sign GCS blob URLs
#

# web_private_key secret
resource "google_secret_manager_secret" "web_private_key" {
  secret_id = "ztl-web-private-key"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# web_private_key read access for web service account
resource "google_secret_manager_secret_iam_member" "web_private_key" {
  secret_id = google_secret_manager_secret.web_private_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# web_private_key value
resource "google_secret_manager_secret_version" "web_private_key" {
  secret      = google_secret_manager_secret.web_private_key.id
  secret_data = base64decode(google_service_account_key.web.private_key)
}

#
# worker_private_key: private key for the worker service account
# needed to be able to sign GCS blob URLs
#

# worker_private_key secret
resource "google_secret_manager_secret" "worker_private_key" {
  secret_id = "ztl-worker-private-key"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# worker_private_key read access for worker service account
resource "google_secret_manager_secret_iam_member" "worker_private_key" {
  secret_id = google_secret_manager_secret.worker_private_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.worker.email}"
}

# worker_private_key value
resource "google_secret_manager_secret_version" "worker_private_key" {
  secret      = google_secret_manager_secret.worker_private_key.id
  secret_data = base64decode(google_service_account_key.worker.private_key)
}

#
# ek_private_key: private key for the ek service account
# needed by elasticsearch to access the bucket
#

# ek_private_key secret
resource "google_secret_manager_secret" "ek_private_key" {
  count     = var.ek_instance_count > 0 ? 1 : 0
  secret_id = "ztl-ek-private-key"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# ek_private_key read access for ek service account
resource "google_secret_manager_secret_iam_member" "ek_private_key" {
  count     = var.ek_instance_count > 0 ? 1 : 0
  secret_id = google_secret_manager_secret.ek_private_key[0].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.ek[0].email}"
}

# ek_private_key value
resource "google_secret_manager_secret_version" "ek_private_key" {
  count       = var.ek_instance_count > 0 ? 1 : 0
  secret      = google_secret_manager_secret.ek_private_key[0].id
  secret_data = base64decode(google_service_account_key.ek[0].private_key)
}

#
# geolite2_license_key: api key for the geolite2 DB updates
#

# geolite2_license_key secret
resource "google_secret_manager_secret" "geolite2_license_key" {
  secret_id = "ztl-geolite2-license-key"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# geolite2_license_key read access for web service accounts
resource "google_secret_manager_secret_iam_member" "geolite2_license_key_web" {
  secret_id = google_secret_manager_secret.geolite2_license_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# geolite2_license_key read access for worker service accounts
resource "google_secret_manager_secret_iam_member" "geolite2_license_key_worker" {
  secret_id = google_secret_manager_secret.geolite2_license_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.worker.email}"
}

# geolite2_license_key value
resource "google_secret_manager_secret_version" "geolite2_license_key" {
  secret      = google_secret_manager_secret.geolite2_license_key.id
  secret_data = var.geolite2_license_key
}

#
# datadog_api_key: api key for the datadog agent
#

# datadog_api_key secret
resource "google_secret_manager_secret" "datadog_api_key" {
  secret_id = "ztl-datadog-api-key"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# datadog_api_key read access for ek service accounts
resource "google_secret_manager_secret_iam_member" "datadog_api_key_ek" {
  count     = var.ek_instance_count > 0 ? 1 : 0
  secret_id = google_secret_manager_secret.datadog_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.ek[0].email}"
}

# datadog_api_key read access for monitoring service accounts
resource "google_secret_manager_secret_iam_member" "datadog_api_key_monitoring" {
  secret_id = google_secret_manager_secret.datadog_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.monitoring.email}"
}

# datadog_api_key read access for web service accounts
resource "google_secret_manager_secret_iam_member" "datadog_api_key_web" {
  secret_id = google_secret_manager_secret.datadog_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# datadog_api_key read access for worker service accounts
resource "google_secret_manager_secret_iam_member" "datadog_api_key_worker" {
  secret_id = google_secret_manager_secret.datadog_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.worker.email}"
}

# datadog_api_key value
resource "google_secret_manager_secret_version" "datadog_api_key" {
  secret      = google_secret_manager_secret.datadog_api_key.id
  secret_data = var.datadog_api_key
}

#
# splunk_hec_token: Token for Splunk HEC
#

# splunk_hec_token secret
resource "google_secret_manager_secret" "splunk_hec_token" {
  secret_id = "ztl-splunk-hec-token"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# splunk_hec_token read access for monitoring service account
# used by ztl_admin for example to see if a prometheus target for the worker needs to be added.
resource "google_secret_manager_secret_iam_member" "splunk_hec_token_monitoring" {
  secret_id = google_secret_manager_secret.splunk_hec_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.monitoring.email}"
}

# splunk_hec_token read access for web service accounts
resource "google_secret_manager_secret_iam_member" "splunk_hec_token_web" {
  secret_id = google_secret_manager_secret.splunk_hec_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# splunk_hec_token read access for worker service accounts
resource "google_secret_manager_secret_iam_member" "splunk_hec_token_worker" {
  secret_id = google_secret_manager_secret.splunk_hec_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.worker.email}"
}

# splunk_hec_token value
resource "google_secret_manager_secret_version" "splunk_hec_token" {
  secret      = google_secret_manager_secret.splunk_hec_token.id
  secret_data = var.splunk_hec_token
}

#
# splunk_api_token: Authentication token for the Splunk API
#

# splunk_api_token secret
resource "google_secret_manager_secret" "splunk_api_token" {
  secret_id = "ztl-splunk-api-token"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# splunk_api_token read access for web service accounts
resource "google_secret_manager_secret_iam_member" "splunk_api_token_web" {
  secret_id = google_secret_manager_secret.splunk_api_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# splunk_api_token value
resource "google_secret_manager_secret_version" "splunk_api_token" {
  secret      = google_secret_manager_secret.splunk_api_token.id
  secret_data = var.splunk_api_token
}

#
# splunk_api_cf_access_client_secret: Clouflare secret for the Splunk API
#

# splunk_api_cf_access_client_secret secret
resource "google_secret_manager_secret" "splunk_api_cf_access_client_secret" {
  secret_id = "ztl-splunk-api-cf-access-client-secret"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# splunk_api_cf_access_client_secret read access for web service accounts
resource "google_secret_manager_secret_iam_member" "splunk_api_cf_access_client_secret_web" {
  secret_id = google_secret_manager_secret.splunk_api_cf_access_client_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# splunk_api_cf_access_client_secret value
resource "google_secret_manager_secret_version" "splunk_api_cf_access_client_secret" {
  secret      = google_secret_manager_secret.splunk_api_cf_access_client_secret.id
  secret_data = var.splunk_api_cf_access_client_secret
}

#
# smtp_relay_password
#

# smtp_relay_password secret
resource "google_secret_manager_secret" "smtp_relay_password" {
  secret_id = "ztl-smtp-relay-password"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# smtp_relay_password read access for ek service accounts
resource "google_secret_manager_secret_iam_member" "smtp_relay_password_ek" {
  count     = var.ek_instance_count > 0 ? 1 : 0
  secret_id = google_secret_manager_secret.smtp_relay_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.ek[0].email}"
}

# smtp_relay_password read access for monitoring service accounts
resource "google_secret_manager_secret_iam_member" "smtp_relay_password_monitoring" {
  secret_id = google_secret_manager_secret.smtp_relay_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.monitoring.email}"
}

# smtp_relay_password read access for web service accounts
resource "google_secret_manager_secret_iam_member" "smtp_relay_password_web" {
  secret_id = google_secret_manager_secret.smtp_relay_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# smtp_relay_password read access for worker service accounts
resource "google_secret_manager_secret_iam_member" "smtp_relay_password_worker" {
  secret_id = google_secret_manager_secret.smtp_relay_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.worker.email}"
}

# smtp_relay_password value
resource "google_secret_manager_secret_version" "smtp_relay_password" {
  secret      = google_secret_manager_secret.smtp_relay_password.id
  secret_data = var.smtp_relay_password
}

#
# crowdstrike_cid
#

# crowdstrike_cid secret
resource "google_secret_manager_secret" "crowdstrike_cid" {
  secret_id = "ztl-crowdstrike-cid"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# crowdstrike_cid read access for ek service accounts
resource "google_secret_manager_secret_iam_member" "crowdstrike_cid_ek" {
  count     = var.ek_instance_count > 0 ? 1 : 0
  secret_id = google_secret_manager_secret.crowdstrike_cid.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.ek[0].email}"
}

# crowdstrike_cid read access for monitoring service accounts
resource "google_secret_manager_secret_iam_member" "crowdstrike_cid_monitoring" {
  secret_id = google_secret_manager_secret.crowdstrike_cid.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.monitoring.email}"
}

# crowdstrike_cid read access for web service accounts
resource "google_secret_manager_secret_iam_member" "crowdstrike_cid_web" {
  secret_id = google_secret_manager_secret.crowdstrike_cid.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# crowdstrike_cid read access for worker service accounts
resource "google_secret_manager_secret_iam_member" "crowdstrike_cid_worker" {
  secret_id = google_secret_manager_secret.crowdstrike_cid.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.worker.email}"
}

# crowdstrike_cid value
resource "google_secret_manager_secret_version" "crowdstrike_cid" {
  secret      = google_secret_manager_secret.crowdstrike_cid.id
  secret_data = var.crowdstrike_cid
}

#
# nessus_key
#

# nessus_key secret
resource "google_secret_manager_secret" "nessus_key" {
  secret_id = "ztl-nessus-key"

  replication {
    user_managed {
      replicas {
        location = data.google_client_config.current.region
      }
    }
  }
}

# nessus_key read access for ek service accounts
resource "google_secret_manager_secret_iam_member" "nessus_key_ek" {
  count     = var.ek_instance_count > 0 ? 1 : 0
  secret_id = google_secret_manager_secret.nessus_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.ek[0].email}"
}

# nessus_key read access for monitoring service accounts
resource "google_secret_manager_secret_iam_member" "nessus_key_monitoring" {
  secret_id = google_secret_manager_secret.nessus_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.monitoring.email}"
}

# nessus_key read access for web service accounts
resource "google_secret_manager_secret_iam_member" "nessus_key_web" {
  secret_id = google_secret_manager_secret.nessus_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.web.email}"
}

# nessus_key read access for worker service accounts
resource "google_secret_manager_secret_iam_member" "nessus_key_worker" {
  secret_id = google_secret_manager_secret.nessus_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.worker.email}"
}

# nessus_key value
resource "google_secret_manager_secret_version" "nessus_key" {
  secret      = google_secret_manager_secret.nessus_key.id
  secret_data = var.nessus_key
}
