terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "~>2.5.0"
    }

    google = {
      source  = "hashicorp/google"
      version = "~>3.65"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~>2.0"
    }
  }
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}
