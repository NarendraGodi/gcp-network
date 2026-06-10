# Shared VPC Host Project Enablement
resource "google_compute_shared_vpc_host_project" "host" {
  project = module.network_host_project.project_id
}

# VPC Network
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 10.0"

  project_id   = module.network_host_project.project_id
  network_name = "vpc-${var.target_env}-shared"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "sb-${var.target_env}-${local.env_config.region}-web"
      subnet_ip     = cidrsubnet(local.env_config.ip_range, 8, 10) # Result: 10.10.10.0/24 for Dev
      subnet_region = local.env_config.region
      description   = "Web Tier for ${var.target_env}"
    },
    {
      subnet_name   = "sb-${var.target_env}-${local.env_config.region}-app"
      subnet_ip     = cidrsubnet(local.env_config.ip_range, 8, 20) # Result: 10.10.20.0/24 for Dev
      subnet_region = local.env_config.region
      description   = "Application Tier for ${var.target_env}"
    },
    {
      subnet_name   = "sb-${var.target_env}-${local.env_config.region}-db"
      subnet_ip     = cidrsubnet(local.env_config.ip_range, 8, 30) # Result: 10.10.30.0/24 for Dev
      subnet_region = local.env_config.region
      description   = "Database Tier for ${var.target_env}"
    }
  ]

  # Ensure VPC is created after the project is ready
  depends_on = [module.network_host_project]
}
