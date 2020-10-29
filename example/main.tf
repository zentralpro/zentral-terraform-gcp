locals {
  project_id   = "my-project-id"
  region       = "us-east1"
  default_zone = "us-east1-c"
}

provider "google" {
  project = local.project_id
  region  = local.region
  zone    = local.default_zone
}

module "vpc" {
  source = "git@github.com:zentralpro/zentral-terraform-gcp.git//modules/vpc?ref=v0.1.0"

  region = local.region
}

module "zentral" {
  source = "git@github.com:zentralpro/zentral-terraform-aws.git//modules/zentral?ref=v0.1.0"

  depends_on   = [module.vpc]
  network_id   = module.vpc.network_id
  network_name = module.vpc.network_name

  project_id   = local.project_id
  region       = local.region
  default_zone = local.default_zone

  admin_email        = "admin@example.com"
  admin_username     = "admin"
  fqdn               = "zentral.example.com"
  default_from_email = "zentral@example.com"
  munki_repo_bucket  = "the-munki-repository-bucket-name"
  base_json          = file("${path.module}/cfg/base.json")

  # DANGER!!! ONLY DEV!!!
  destroy_all_resources = true
}
