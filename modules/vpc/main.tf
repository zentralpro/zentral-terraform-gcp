terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>3.51.1"
    }
  }
}

data "google_client_config" "current" {}
