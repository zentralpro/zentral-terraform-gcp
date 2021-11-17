#
# web instances
#

# latest web image when terraform runs
data "google_compute_image" "web_latest" {
  family  = "ztl-web"
  project = var.images_project
}

# provided web image
data "google_compute_image" "web" {
  count   = var.web_image == "LATEST" ? 0 : 1
  name    = var.web_image
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
    source_image = var.web_image == "LATEST" ? data.google_compute_image.web_latest.self_link : data.google_compute_image.web[0].self_link
    disk_type    = "pd-ssd"
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

# managed instance group for the web instances
resource "google_compute_region_instance_group_manager" "web" {
  name = "ztl-web-mig"

  base_instance_name = "ztl-web"
  region             = data.google_client_config.current.region

  target_pools = [google_compute_target_pool.web.id]
  target_size  = var.web_mig_target_size

  version {
    instance_template = google_compute_instance_template.web.id
  }

  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_unavailable_fixed        = 0
    max_surge_fixed              = max(3, var.web_mig_target_size)
    min_ready_sec                = 120
  }
}

#
# worker instances
#

# latest worker image when terraform runs
data "google_compute_image" "worker_latest" {
  family  = "ztl-worker"
  project = var.images_project
}

# provided worker image
data "google_compute_image" "worker" {
  count   = var.worker_image == "LATEST" ? 0 : 1
  name    = var.worker_image
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
    source_image = var.worker_image == "LATEST" ? data.google_compute_image.worker_latest.self_link : data.google_compute_image.worker[0].self_link
    disk_type    = "pd-ssd"
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

# managed instance group for the worker instances
resource "google_compute_region_instance_group_manager" "worker" {
  name = "ztl-worker-mig"

  base_instance_name = "ztl-worker"
  region             = data.google_client_config.current.region

  target_size = var.worker_mig_target_size

  version {
    instance_template = google_compute_instance_template.worker.id
  }

  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_unavailable_fixed        = 0
    max_surge_fixed              = max(3, var.worker_mig_target_size)
    min_ready_sec                = 120
  }
}

#
# ek instances
#

# latest ek image when terraform runs
data "google_compute_image" "ek_latest" {
  family  = "ztl-ek"
  project = var.images_project
}

# provided ek image
data "google_compute_image" "ek" {
  count   = var.ek_image == "LATEST" ? 0 : 1
  name    = var.ek_image
  project = var.images_project
}

# ek instance elasticsearch data disk {
resource "google_compute_disk" "elasticsearch" {
  name = "ztl-ek-elasticsearch-data"
  size = var.ek_data_disk_size
  type = "pd-ssd"
}

# ek instance reserved internal address
resource "google_compute_address" "ek" {
  name         = "ztl-ek"
  subnetwork   = var.subnetwork_name
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
}

# elasticsearch kibana instance
resource "google_compute_instance" "ek1" {
  name         = "ztl-ek-1"
  machine_type = var.ek_machine_type
  tags         = ["elastic", "kibana", "ssh"]
  labels = {
    ztl-sa-short-name = "ek"
  }

  boot_disk {
    initialize_params {
      image = var.ek_image == "LATEST" ? data.google_compute_image.ek_latest.self_link : data.google_compute_image.ek[0].self_link
      size  = 10
      type  = "pd-ssd"
    }
  }

  attached_disk {
    source      = google_compute_disk.elasticsearch.self_link
    device_name = "elasticsearch"
  }

  network_interface {
    subnetwork = var.subnetwork_name
    network_ip = google_compute_address.ek.address
  }

  service_account {
    email  = google_service_account.ek.email
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

# latest monitoring image when terraform runs
data "google_compute_image" "monitoring_latest" {
  family  = "ztl-monitoring"
  project = var.images_project
}

# provided monitoring image
data "google_compute_image" "monitoring" {
  count   = var.monitoring_image == "LATEST" ? 0 : 1
  name    = var.monitoring_image
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
  count        = local.monitoring_instance_count
  name         = "ztl-monitoring"
  machine_type = var.monitoring_machine_type
  tags         = ["monitoring", "ssh"]
  labels = {
    ztl-sa-short-name = "monitoring"
  }

  boot_disk {
    initialize_params {
      image = var.monitoring_image == "LATEST" ? data.google_compute_image.monitoring_latest.self_link : data.google_compute_image.monitoring[0].self_link
      size  = 10
      type  = "pd-ssd"
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
