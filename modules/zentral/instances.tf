#
# web instances
#

# latest web image when terraform runs
data "google_compute_image" "web" {
  family  = "ztl-web"
  project = var.images_project
}

# instance template for the web instances
resource "google_compute_instance_template" "web" {
  name_prefix = "ztl-web-instance-template-"
  description = "Zentral template used for the web instances"

  machine_type = var.web_machine_type
  tags         = ["web", "ssh"]

  disk {
    source_image = data.google_compute_image.web.self_link
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
ztl_admin --no-ts setup
EOT

  lifecycle {
    create_before_destroy = true
  }

}

# managed instance group for the web instances
resource "google_compute_region_instance_group_manager" "web" {
  name = "ztl-web-mig"

  version {
    instance_template = google_compute_instance_template.web.id
  }

  base_instance_name = "ztl-web"
  region             = data.google_client_config.current.region

  target_pools = [google_compute_target_pool.web.id]
  target_size  = var.web_mig_target_size
}

#
# worker instances
#

# latest worker image when terraform runs
data "google_compute_image" "worker" {
  family  = "ztl-worker"
  project = var.images_project
}

# instance template for the worker instances
resource "google_compute_instance_template" "worker" {
  name_prefix = "ztl-worker-instance-template-"
  description = "Zentral template used for the worker instances"

  machine_type = var.worker_machine_type
  tags         = ["worker", "ssh"]

  disk {
    source_image = data.google_compute_image.worker.self_link
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
ztl_admin --no-ts setup
EOT

  lifecycle {
    create_before_destroy = true
  }

}

# managed instance group for the worker instances
resource "google_compute_region_instance_group_manager" "worker" {
  name = "ztl-worker-mig"

  version {
    instance_template = google_compute_instance_template.worker.id
  }

  base_instance_name = "ztl-worker"
  region             = data.google_client_config.current.region

  target_size = var.worker_mig_target_size
}

#
# ek instances
#

# elasticsearch kibana instance
resource "google_compute_instance" "ek1" {
  name         = "ztl-ek-1"
  machine_type = var.ek_machine_type
  tags         = ["elastic", "kibana", "ssh"]

  boot_disk {
    initialize_params {
      image = "projects/${var.images_project}/global/images/family/ztl-ek"
      size  = 30
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = var.subnetwork_name
  }

  service_account {
    email  = google_service_account.ek.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<EOT
#!/bin/bash
ztl_admin --no-ts setup
EOT

}
