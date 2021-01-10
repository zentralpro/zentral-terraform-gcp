terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>3.51.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0.0"
    }
  }
}

data "google_client_config" "current" {}
