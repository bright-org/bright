terraform {
  required_version = "~> 1.5.2"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.72.0"
    }
  }

  backend "remote" {
    organization = "bright-org"

    workspaces {
      name = "bright-stg"
    }
  }
}
