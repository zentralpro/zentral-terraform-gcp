terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>3.45.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0.0"
    }
  }
}
