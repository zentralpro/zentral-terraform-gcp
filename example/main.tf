provider "google" {
  project = "my-project-id"
  region  = "us-east1"
  zone    = "us-east1-c"
}

module "vpc" {
  source = "git@github.com:zentralpro/zentral-terraform-gcp.git//modules/vpc?ref=v0.1.0"
}

module "zentral" {
  source = "git@github.com:zentralpro/zentral-terraform-gcp.git//modules/zentral?ref=v0.1.0"

  depends_on      = [module.vpc]
  network_id      = module.vpc.network_id
  network_name    = module.vpc.network_name
  subnetwork_name = module.vpc.subnetwork_name

  admin_email        = "admin@example.com"
  admin_username     = "admin"
  fqdn               = "zentral.example.com"
  default_from_email = "zentral@example.com"
  munki_repo_bucket  = "the-munki-repository-bucket-name"
  base_json          = file("${path.module}/cfg/base.json")

  # DANGER!!! ONLY DEV!!!
  destroy_all_resources = true
}
