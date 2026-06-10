terraform {
  cloud {
    organization = "narendragodi-cv"

    workspaces {
      tags = ["networking"]
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  # Configuration via TFC environment variables:
  # GOOGLE_CREDENTIALS, GOOGLE_PROJECT, etc.
}

locals {
  foundation_data = jsondecode(file("${path.module}/foundation_layer.json"))
  billing_account = "015CC7-496842-8E745D"
  
  # Select the data for the target environment
  env_config = local.foundation_data[var.target_env]
}

# Network Host Project for the specific environment
module "network_host_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 17.0"

  name              = "ng-${var.target_env}-net-host"
  random_project_id = true
  org_id            = "997580462738"
  folder_id         = split("/", local.env_config.network_parent)[1]
  billing_account   = local.billing_account

  activate_apis = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}
