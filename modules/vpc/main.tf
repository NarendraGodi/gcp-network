module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 10.0"

  project_id   = var.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"

  subnets = [
    for name, config in var.subnets : {
      subnet_name   = "sb-${var.target_env}-${var.region}-${name}"
      subnet_ip     = cidrsubnet(var.ip_range, 8, config.offset)
      subnet_region = var.region
      description   = "${config.description} for ${var.target_env}"
    }
  ]
}
