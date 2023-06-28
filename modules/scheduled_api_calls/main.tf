terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>3.65"
    }
  }
}

data "google_client_config" "current" {}
