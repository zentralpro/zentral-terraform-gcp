module "project" {
  source                    = "git@github.com:zentralpro/zentral-terraform-gcp.git//modules/project"
  name                      = "Zentral test deployment"
  project_id                = "unique-project-slug"
  org_id                    = "0000000000000"
  billing_account           = "000000-000000-000000"
  terraform_bucket_location = "US"
}
