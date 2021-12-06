# terraform gcs backend
terraform {
  backend "gcs" {
    # replace with name of the bucket for the terraform backend
    bucket = "NAME_OF_THE_BUCKET"
    # a prefix can be used if the bucket is shared among many terraform deployments
    # prefix = ""
  }
}


# terraform google provider
provider "google" {
  # the google cloud project
  project = "my-project-id"
  # default region
  region = "us-east1"
  # default zone
  zone = "us-east1-c"
}


# automatically enable the required APIs on the project
resource "google_project_service" "service" {
  for_each = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
    "pubsub.googleapis.com",
    "redis.googleapis.com",
    # for the cloud function
    # "appengine.googleapis.com",
    # "cloudbuild.googleapis.com",
    # "cloudfunctions.googleapis.com",
    # "cloudscheduler.googleapis.com",
  ])

  service            = each.key
  disable_on_destroy = false
}

# the zentral VPC
module "vpc" {
  source = "git@github.com:zentralpro/zentral-terraform-gcp.git//modules/vpc?ref=v0.2.11"

  depends_on = [
    google_project_service.service
  ]

  # The CIDR block for the subnet
  # subnet = "10.0.1.0/24"

  # To "manually" set the IP addresses used by the NAT router
  # 0 → the NAT router will be set to automatically allocate IP addresses
  # see https://cloud.google.com/nat/docs/ports-and-addresses#addresses
  # manual_nat_ip_address_count = 0
}

# the main zentral module
module "zentral" {
  source = "git@github.com:zentralpro/zentral-terraform-gcp.git//modules/zentral?ref=v0.2.11"

  depends_on = [
    google_project_service.service
  ]

  network_id      = module.vpc.network_id
  subnetwork_name = module.vpc.subnetwork_name


  ##########################
  # FQDN / mTLS / DNS / IP #
  ##########################

  fqdn = "zentral.example.com"
  # fqdn_mtls = "UNDEFINED"

  # to load the certificate, issuer chain, and private key from the cfg/ local subdir, if present
  tls_cert    = fileexists("${path.module}/cfg/cert.pem") ? file("${path.module}/cfg/cert.pem") : "UNDEFINED"
  tls_chain   = fileexists("${path.module}/cfg/chain.pem") ? file("${path.module}/cfg/chain.pem") : "UNDEFINED"
  tls_privkey = fileexists("${path.module}/cfg/privkey.pem") ? file("${path.module}/cfg/privkey.pem") : "UNDEFINED"

  # to load the cachain.pem file from the cfg/ subdir, if present
  # NOTE: both fqdn_mtls and cachain.pem need to be set to enable the mTLS endpoint
  tls_cachain = fileexists("${path.module}/cfg/cachain.pem") ? file("${path.module}/cfg/cachain.pem") : "UNDEFINED"

  # Optional, configure the Nginx http realip module, if a proxy is used in front of the load balancer.
  # List of trusted addresses that are known to send correct replacement addresses
  # set_real_ip_from = []
  # Request header field whose value will be used to replace the client address.
  # real_ip_header = null
  #
  # for example, for clouflare:
  # see https://www.cloudflare.com/en-gb/ips/
  # last retrieved 2021-04-13
  # set_real_ip_from = [
  #  "173.245.48.0/20",
  #  "103.21.244.0/22",
  #  "103.22.200.0/22",
  #  "103.31.4.0/22",
  #  "141.101.64.0/18",
  #  "108.162.192.0/18",
  #  "190.93.240.0/20",
  #  "188.114.96.0/20",
  #  "197.234.240.0/22",
  #  "198.41.128.0/17",
  #  "162.158.0.0/15",
  #  "104.16.0.0/13",
  #  "104.24.0.0/14",
  #  "172.64.0.0/13",
  #  "131.0.72.0/22",
  #]
  # real_ip_header = "CF-Connecting-IP"

  # Activate or deactivate the collection of the Nginx access log.
  # Activated by default.
  # collect_nginx_access_log = true


  ############################
  # SMTP relay configuration #
  ############################

  # default_from_email  = "UNDEFINED"
  # smtp_relay_host     = "UNDEFINED"
  # smtp_relay_user     = "UNDEFINED"

  # smtp_relay_password is a secret, so it is defined in variables.tf,
  # and can be passed in the environment. Do not set it here.
  # default = "UNDEFINED" → the SMTP relay will not be configured.
  # smtp_relay_password = var.smtp_relay_password

  # If this list is empty, all domains are allowed
  # smtp_allowed_recipient_domains = []


  #########################
  # Zentral configuration #
  #########################

  # superadmin credentials
  admin_email    = "admin@example.com"
  admin_username = "admin"

  # the base.json skeleton that ztl_admin is going to use as template
  # place a base.json file in the cfg/ subdir, and it will be loaded
  base_json = file("${path.module}/cfg/base.json")


  #############################
  # machine types and numbers #
  #############################

  # Web: 1 ⨉ vCPU, 1GB
  # web_machine_type = "custom-1-1024"
  # Target size of the managed instance group
  # web_mig_target_size = 2
  # Image. Change this if you want to pin a version
  # web_image = "LATEST"

  # Worker: 1 ⨉ vCPU, 1GB
  # worker_machine_type = "custom-1-1024"
  # Target size of the managed instance group
  # worker_mig_target_size = 1
  # Image. Change this if you want to pin a version
  # worker_image = "LATEST"

  # Elasticsearch + Kibana
  # set ek_instance_count to 0 to remove all the resources
  # required to maintain the Elasticsearch event store.
  # ek_instance_count = 1
  # 1 ⨉ vCPU, 5GB
  # ek_machine_type = "custom-1-5120"
  # Image. Change this if you want to pin a version
  # ek_image = "LATEST"
  # Data disk size, in GB
  # ek_data_disk_size = 30

  # DB: 1 ⨉ vCPU, 3.75GB (to unlock the 100 connections)
  # db_tier = db-custom-1-3840

  # Monitoring (Grafana + Prometheus): 1 ⨉ vCPU, 1GB
  # monitoring_machine_type = "custom-1-1024"
  # Image. Change this if you want to pin a version
  # monitoring_image = "LATEST"


  #############
  # DB Backup #
  #############

  # db_backup_enabled = false

  # db_backup_start_time = "00:00"
  # Beginning (24-hour time, UTC) of a 4-hour backup window

  # db_backup_count = 7
  # Number of daily backups retained. Min 7, max 366

  # db_point_in_time_recovery_enabled = false
  # To enable point-in-time recovery

  # db_transaction_log_retention_days = 7
  # Number of days of transaction logs retained. Min 1, max 7


  ####################
  # Datadog settings #
  ####################

  # Datadog site: change it to datadoghq.eu if necessary
  # datadog_site = "datadoghq.com"
  # Datadog service: to filter the events
  # datadog_service = "Zentral"

  # datadog_api_key is a secret, so it is defined in variables.tf,
  # and can be passed in the environment. Do not set it here.
  # default = "UNDEFINED" → Datadog will not be configured.
  # datadog_api_key = var.datadog_api_key


  ##########
  # Splunk #
  ##########

  # splunk_hec_token is a secret, so it is defined in variables.tf,
  # and can be passed in the environment. Do not set it here.
  # default = "UNDEFINED" → it will not be added to an eventual
  # splunk store in base.json.
  # splunk_hec_token = var.splunk_hec_token

  # splunk_api_token is a secret, so it is defined in variables.tf,
  # and can be passed in the environment. Do not set it here.
  # default = "UNDEFINED" → it will not be added to an eventual
  # splunk store in base.json.
  # splunk_api_token = var.splunk_api_token

  # splunk_api_cf_access_client_secret is a secret, so it is defined in variables.tf,
  # and can be passed in the environment. Do not set it here.
  # default = "UNDEFINED" → it will not be added to an eventual
  # splunk store in base.json.
  # splunk_api_cf_access_client_secret = var.splunk_api_cf_access_client_secret


  ########################
  # Geolite2 credentials #
  ########################

  # geolite2_account_id = "UNDEFINED"

  # geolite2_license_key is a secret, so it is defined in variables.tf,
  # and can be passed in the environment. Do not set it here.
  # default = "UNDEFINED" → Geolite2 will not be configured.
  # For more information, see https://dev.maxmind.com/geoip/geoip2/geolite2/
  # geolite2_license_key = var.geolite2_license_key


  ############################
  # CrowdStrike Falcon agent #
  ############################

  # The relative name of the debian package in the dist bucket that will be
  # installed on the instances.
  # crowdstrike_deb = "UNDEFINED"

  # crowdstrike_cid is a secret, so it is defined in variables.tf,
  # and can be passed in the environment. Do not set it here.
  # default = "UNDEFINED" → The CrowdStrike Falcon agent will not be
  # configured.
  # crowdstrike_cid = var.crowdstrike_cid

  ##########################
  # Certbot cloud function #
  ##########################

  # certbot_cloud_function = false

  # cloudflare_api_token is a secret, so it is defined in variables.tf,
  # and can be passed in the environment. Do not set it here.
  # cloudflare_api_token   = var.cloudflare_api_token

  #################
  # Obscure stuff #
  #################

  # DANGER!!! ONLY DEV!!!
  # Set to true during testing to remove the db deletion protection and allow non-empty bucket deletion
  # destroy_all_resources = false
}
