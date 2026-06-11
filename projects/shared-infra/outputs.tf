output "project_id" {
  description = "The ID of the created host project"
  value       = module.landing_zone.project_id
}

output "project_number" {
  description = "The number of the created host project"
  value       = module.landing_zone.project_number
}

output "vpc_name" {
  description = "The name of the Shared VPC"
  value       = module.landing_zone.vpc_name
}
