module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 10.0"

  project_id   = var.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "sb-${var.target_env}-${var.region}-web"
      subnet_ip     = cidrsubnet(var.ip_range, 8, 10)
      subnet_region = var.region
      description   = "Web Tier for ${var.target_env}"
    },
    {
      subnet_name   = "sb-${var.target_env}-${var.region}-app"
      subnet_ip     = cidrsubnet(var.ip_range, 8, 20)
      subnet_region = var.region
      description   = "Application Tier for ${var.target_env}"
    },
    {
      subnet_name   = "sb-${var.target_env}-${var.region}-db"
      subnet_ip     = cidrsubnet(var.ip_range, 8, 30)
      subnet_region = var.region
      description   = "Database Tier for ${var.target_env}"
    }
  ]
}
