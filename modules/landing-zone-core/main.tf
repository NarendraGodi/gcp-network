# Network Host Project for the specific environment
module "network_host_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 17.0"

  name              = "ng-${var.target_env}-net-host-v2"
  random_project_id = true
  org_id            = var.org_id
  folder_id         = split("/", var.network_parent)[1]
  billing_account   = var.billing_account
  deletion_policy   = var.deletion_policy

  activate_apis = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com"
  ]
}

# Shared VPC Host Project Enablement
resource "google_compute_shared_vpc_host_project" "host" {
  project    = module.network_host_project.project_id
  depends_on = [module.network_host_project]
}
