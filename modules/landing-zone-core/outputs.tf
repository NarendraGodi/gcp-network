output "project_id" {
  description = "The ID of the created host project"
  value       = module.network_host_project.project_id
}

output "project_number" {
  description = "The number of the created host project"
  value       = module.network_host_project.project_number
}

output "vpc_name" {
  description = "The name of the Shared VPC"
  value       = module.vpc.network_name
}

output "subnets" {
  description = "The subnets created in the Shared VPC"
  value       = module.vpc.subnets
}
