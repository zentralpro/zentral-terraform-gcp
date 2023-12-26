#
# web instances
#

# provided web image by ID
data "google_compute_image" "web_by_id" {
  count   = var.web_image_id == "LATEST" ? 0 : 1
  filter  = "id = \"${var.web_image_id}\""
  project = var.images_project
}

# provided web image
data "google_compute_image" "web" {
  count   = var.web_image == "LATEST" ? 0 : 1
  name    = var.web_image
  project = var.images_project
}

# latest web image when terraform runs
data "google_compute_image" "web_latest" {
  count   = var.web_image_id == "LATEST" && var.web_image == "LATEST" ? 1 : 0
  family  = length(regexall("^t2a.*", var.web_machine_type)) > 0 ? "ztl-web-arm64" : "ztl-web"
  project = var.images_project
}

# instance template for the web instances
resource "google_compute_instance_template" "web" {
  name_prefix = "ztl-web-instance-template-"
  description = "Zentral template used for the web instances"

  machine_type = var.web_machine_type
  tags         = ["web", "ssh"]
  labels = {
    ztl-sa-short-name = "web"
  }

  disk {
    source_image = element(concat(
      data.google_compute_image.web_by_id[*].self_link,
      data.google_compute_image.web[*].self_link,
      data.google_compute_image.web_latest[*].self_link,
    ), 0)
    disk_type    = "pd-ssd"
    disk_size_gb = var.web_instance_disk_size
  }

  network_interface {
    subnetwork = var.subnetwork_name
  }

  service_account {
    email  = google_service_account.web.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<EOT
#!/bin/bash
systemctl start google-guest-agent
ztl_admin --no-ts setup
EOT

  lifecycle {
    create_before_destroy = true
  }

}

# autohealing health check for the web instances
resource "google_compute_health_check" "web_mig" {
  name                = "ztl-web-mig-autohealing-health-check"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 1
  unhealthy_threshold = 3

  http_health_check {
    request_path = "/instance-health-check"
    port         = "8081"
  }
}

# managed instance group for the web instances
resource "google_compute_region_instance_group_manager" "web" {
  name = "ztl-web-mig"

  base_instance_name        = "ztl-web"
  region                    = data.google_client_config.current.region
  distribution_policy_zones = var.web_mig_distribution_policy_zones

  target_pools = [google_compute_target_pool.web.id]
  target_size  = var.web_mig_target_size

  version {
    instance_template = google_compute_instance_template.web.id
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.web_mig.id
    initial_delay_sec = 1200
  }

  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_unavailable_fixed        = 0
    max_surge_fixed              = max(3, var.web_mig_target_size)
  }

  lifecycle {
    ignore_changes = [
      version.0.name
    ]
  }
}

#
# worker instances
#

# provided worker image by ID
data "google_compute_image" "worker_by_id" {
  count   = var.worker_image_id == "LATEST" ? 0 : 1
  filter  = "id = \"${var.worker_image_id}\""
  project = var.images_project
}

# provided worker image
data "google_compute_image" "worker" {
  count   = var.worker_image == "LATEST" ? 0 : 1
  name    = var.worker_image
  project = var.images_project
}

# latest worker image when terraform runs
data "google_compute_image" "worker_latest" {
  count   = var.worker_image_id == "LATEST" && var.worker_image == "LATEST" ? 1 : 0
  family  = length(regexall("^t2a.*", var.worker_machine_type)) > 0 ? "ztl-worker-arm64" : "ztl-worker"
  project = var.images_project
}

# instance template for the worker instances
resource "google_compute_instance_template" "worker" {
  name_prefix = "ztl-worker-instance-template-"
  description = "Zentral template used for the worker instances"

  machine_type = var.worker_machine_type
  tags         = ["worker", "ssh"]
  labels = {
    ztl-sa-short-name = "worker"
  }

  disk {
    source_image = element(concat(
      data.google_compute_image.worker_by_id[*].self_link,
      data.google_compute_image.worker[*].self_link,
      data.google_compute_image.worker_latest[*].self_link,
    ), 0)
    disk_type    = "pd-ssd"
    disk_size_gb = var.worker_instance_disk_size
  }

  network_interface {
    subnetwork = var.subnetwork_name
  }

  service_account {
    email  = google_service_account.worker.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<EOT
#!/bin/bash
systemctl start google-guest-agent
ztl_admin --no-ts setup
EOT

  lifecycle {
    create_before_destroy = true
  }

}

# autohealing health check for the worker instances
resource "google_compute_health_check" "worker_mig" {
  name                = "ztl-worker-mig-autohealing-health-check"
  check_interval_sec  = 30
  timeout_sec         = 10
  healthy_threshold   = 1
  unhealthy_threshold = 5

  # the first worker prometheus metrics endpoint is used
  http_health_check {
    request_path = "/metrics"
    port         = "9910"
  }
}

# managed instance group for the worker instances
resource "google_compute_region_instance_group_manager" "worker" {
  name = "ztl-worker-mig"

  base_instance_name        = "ztl-worker"
  region                    = data.google_client_config.current.region
  distribution_policy_zones = var.worker_mig_distribution_policy_zones

  target_size = var.worker_mig_target_size

  version {
    instance_template = google_compute_instance_template.worker.id
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.worker_mig.id
    initial_delay_sec = 1200
  }

  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_unavailable_fixed        = 0
    max_surge_fixed              = max(3, var.worker_mig_target_size)
  }

  lifecycle {
    ignore_changes = [
      version.0.name
    ]
  }
}

#
# ek instances
#

# provided ek image by ID
data "google_compute_image" "ek_by_id" {
  count   = var.ek_image_id == "LATEST" ? 0 : 1
  filter  = "id = \"${var.ek_image_id}\""
  project = var.images_project
}

# provided ek image
data "google_compute_image" "ek" {
  count   = var.ek_image == "LATEST" ? 0 : 1
  name    = var.ek_image
  project = var.images_project
}

# latest ek image when terraform runs
data "google_compute_image" "ek_latest" {
  count   = var.ek_image_id == "LATEST" && var.ek_image == "LATEST" ? 1 : 0
  family  = length(regexall("^t2a.*", var.ek_machine_type)) > 0 ? "ztl-ek-arm64" : "ztl-ek"
  project = var.images_project
}

# ek instance elasticsearch data disk {
resource "google_compute_disk" "elasticsearch" {
  count = var.ek_instance_count > 0 ? 1 : 0
  name  = "ztl-ek-elasticsearch-data"
  size  = var.ek_data_disk_size
  type  = "pd-ssd"
}

# ek instance reserved internal address
resource "google_compute_address" "ek" {
  count        = var.ek_instance_count > 0 ? 1 : 0
  name         = "ztl-ek"
  subnetwork   = var.subnetwork_name
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
}

# elasticsearch kibana instance
resource "google_compute_instance" "ek1" {
  count        = var.ek_instance_count > 0 ? 1 : 0
  name         = "ztl-ek-1"
  machine_type = var.ek_machine_type
  tags         = ["elastic", "kibana", "ssh"]
  labels = {
    ztl-sa-short-name = "ek"
  }

  boot_disk {
    initialize_params {
      image = element(concat(
        data.google_compute_image.ek_by_id[*].self_link,
        data.google_compute_image.ek[*].self_link,
        data.google_compute_image.ek_latest[*].self_link,
      ), 0)
      size = var.ek_instance_disk_size
      type = "pd-ssd"
    }
  }

  attached_disk {
    source      = google_compute_disk.elasticsearch[0].self_link
    device_name = "elasticsearch"
  }

  network_interface {
    subnetwork = var.subnetwork_name
    network_ip = google_compute_address.ek[0].address
  }

  service_account {
    email  = google_service_account.ek[0].email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<EOT
#!/bin/bash
systemctl start google-guest-agent
ztl_admin --no-ts setup
EOT

  lifecycle {
    ignore_changes = [
      metadata_startup_script,
      boot_disk.0.initialize_params.0.size
    ]
  }
}

#
# monitoring instance
#

# provided monitoring image by ID
data "google_compute_image" "monitoring_by_id" {
  count   = var.monitoring_image_id == "LATEST" ? 0 : 1
  filter  = "id = \"${var.monitoring_image_id}\""
  project = var.images_project
}

# provided monitoring image
data "google_compute_image" "monitoring" {
  count   = var.monitoring_image == "LATEST" ? 0 : 1
  name    = var.monitoring_image
  project = var.images_project
}

# latest monitoring image when terraform runs
data "google_compute_image" "monitoring_latest" {
  count   = var.monitoring_image_id == "LATEST" && var.monitoring_image == "LATEST" ? 1 : 0
  family  = length(regexall("^t2a.*", var.monitoring_machine_type)) > 0 ? "ztl-monitoring-arm64" : "ztl-monitoring"
  project = var.images_project
}

# monitoring instance prometheus data disk {
resource "google_compute_disk" "prometheus" {
  count = local.monitoring_instance_count
  name  = "ztl-monitoring-prometheus-data"
  size  = 20
  type  = "pd-ssd"
}

# monitoring instance grafana data disk {
resource "google_compute_disk" "grafana" {
  count = local.monitoring_instance_count
  name  = "ztl-monitoring-grafana-data"
  size  = 1
  type  = "pd-ssd"
}

# monitoring instance reserved internal address
resource "google_compute_address" "monitoring" {
  count        = local.monitoring_instance_count
  name         = "ztl-monitoring"
  subnetwork   = var.subnetwork_name
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
}

# monitoring instance
resource "google_compute_instance" "monitoring" {
  count                     = local.monitoring_instance_count
  name                      = "ztl-monitoring"
  machine_type              = var.monitoring_machine_type
  allow_stopping_for_update = true
  tags                      = ["monitoring", "ssh"]
  labels = {
    ztl-sa-short-name = "monitoring"
  }

  boot_disk {
    initialize_params {
      image = element(concat(
        data.google_compute_image.monitoring_by_id[*].self_link,
        data.google_compute_image.monitoring[*].self_link,
        data.google_compute_image.monitoring_latest[*].self_link,
      ), 0)
      size = var.monitoring_instance_disk_size
      type = "pd-ssd"
    }
  }

  attached_disk {
    source      = google_compute_disk.prometheus[0].self_link
    device_name = "prometheus"
  }

  attached_disk {
    source      = google_compute_disk.grafana[0].self_link
    device_name = "grafana"
  }

  network_interface {
    subnetwork = var.subnetwork_name
    network_ip = google_compute_address.monitoring[0].address
  }

  service_account {
    email  = google_service_account.monitoring.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<EOT
#!/bin/bash
systemctl start google-guest-agent
ztl_admin --no-ts setup
EOT

  lifecycle {
    ignore_changes = [
      metadata_startup_script,
    ]
  }
}

#
# vault instance
#

# provided vault image by ID
data "google_compute_image" "vault_by_id" {
  count   = var.vault_image_id == "LATEST" ? 0 : 1
  filter  = "id = \"${var.vault_image_id}\""
  project = var.images_project
}

# provided vault image
data "google_compute_image" "vault" {
  count   = var.vault_image == "LATEST" ? 0 : 1
  name    = var.vault_image
  project = var.images_project
}

# latest vault image when terraform runs
data "google_compute_image" "vault_latest" {
  count   = var.vault_image_id == "LATEST" && var.vault_image == "LATEST" ? 1 : 0
  family  = length(regexall("^t2a.*", var.vault_machine_type)) > 0 ? "ztl-vault-arm64" : "ztl-vault"
  project = var.images_project
}

# vault instance data disk {
resource "google_compute_disk" "vault" {
  count = var.vault_instance_count > 0 ? 1 : 0
  name  = "ztl-vault-data"
  size  = 10
  type  = "pd-ssd"
}

# vault instance reserved internal address
resource "google_compute_address" "vault" {
  count        = var.vault_instance_count > 0 ? 1 : 0
  name         = "ztl-vault"
  subnetwork   = var.subnetwork_name
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
}

# vault instance
resource "google_compute_instance" "vault" {
  count                     = var.vault_instance_count > 0 ? 1 : 0
  name                      = "ztl-vault"
  machine_type              = var.vault_machine_type
  allow_stopping_for_update = true
  tags                      = ["vault", "ssh"]
  labels = {
    ztl-sa-short-name = "vault"
  }

  boot_disk {
    initialize_params {
      image = element(concat(
        data.google_compute_image.vault_by_id[*].self_link,
        data.google_compute_image.vault[*].self_link,
        data.google_compute_image.vault_latest[*].self_link,
      ), 0)
      size = var.vault_instance_disk_size
      type = "pd-ssd"
    }
  }

  attached_disk {
    source      = google_compute_disk.vault[0].self_link
    device_name = "vault"
  }

  network_interface {
    subnetwork = var.subnetwork_name
    network_ip = google_compute_address.vault[0].address
  }

  service_account {
    email  = google_service_account.vault[0].email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<EOT
#!/bin/bash
systemctl start google-guest-agent
ztl_admin --no-ts setup
EOT

  lifecycle {
    ignore_changes = [
      metadata_startup_script,
    ]
  }
}
