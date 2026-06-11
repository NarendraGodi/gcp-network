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
  
  # Select the data for the target environment
  env_config = local.foundation_data[var.target_env]
  common     = local.foundation_data["common"]
}

# Core Landing Zone Logic
module "landing_zone" {
  source = "../../modules/landing-zone-core"

  target_env      = var.target_env
  org_id          = local.common.org_id
  billing_account = local.common.billing_account
  network_parent  = local.env_config.network_parent.id
  region          = local.env_config.region
  ip_range        = local.env_config.ip_range
}
