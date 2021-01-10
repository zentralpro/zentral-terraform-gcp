provider "google" {
  # the google cloud project
  project = "my-project-id"
  # default region
  region = "us-east1"
  # default zone
  zone = "us-east1-c"
}

module "vpc" {
  source = "git@github.com:zentralpro/zentral-terraform-gcp.git//modules/vpc?ref=v0.1.0"

  depends_on = [
    google_project_service.service
  ]

  # The CIDR block for the subnet
  # subnet = "10.0.1.0/24"
}

module "zentral" {
  source = "git@github.com:zentralpro/zentral-terraform-gcp.git//modules/zentral?ref=v0.1.0"

  network_id      = module.vpc.network_id
  subnetwork_name = module.vpc.subnetwork_name


  #####################
  # FQDN / mTLS / DNS #
  #####################

  fqdn = "zentral.example.com"
  # fqdn_mtls = "UNDEFINED"

  # to load the cachain.pem file from the cfg/ subdir, if present
  # NOTE: both fqdn_mtls and cachain.pem need to be set to enable the mTLS endpoint
  tls_cachain = fileexists("${path.module}/cfg/cachain.pem") ? file("${path.module}/cfg/cachain.pem") : "UNDEFINED"


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


  #########################
  # Zentral configuration #
  #########################

  # superadmin credentials
  admin_email    = "admin@example.com"
  admin_username = "admin"

  # the base.json skeleton that ztl_admin is going to use as template
  # place a base.json file in the cfg/ subdir, and it will be loaded
  base_json = file("${path.module}/cfg/base.json")


  #################
  # machine types #
  #################

  # Web: 1 ⨉ vCPU, 1GB
  # web_machine_type = "custom-1-1024"

  # Worker: 1 ⨉ vCPU, 1GB
  # worker_machine_type = "custom-1-1024"

  # Elasticsearch + Kibana: 1 ⨉ vCPU, 5GB
  # ek_machine_type = "custom-1-5120"

  # DB: 1 ⨉ vCPU, 3.75GB (to unlock the 100 connections)
  # db_tier = db-custom-1-3840


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


  ########################
  # Geolite2 credentials #
  ########################

  # geolite2_account_id = "UNDEFINED"

  # geolite2_license_key is a secret, so it is defined in variables.tf,
  # and can be passed in the environment. Do not set it here.
  # default = "UNDEFINED" → Geolite2 will not be configured.
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


  #################
  # Obscure stuff #
  #################

  # DANGER!!! ONLY DEV!!!
  # Set to true during testing to remove the db deletion protection and allow non-empty bucket deletion
  # destroy_all_resources = false
}
