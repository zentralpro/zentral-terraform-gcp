terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>3.45.0"
    }
  }
}

data "google_client_config" "current" {}
