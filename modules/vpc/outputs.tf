output "network_name" {
  description = "The name of the VPC"
  value       = module.vpc.network_name
}

output "network_id" {
  description = "The ID of the VPC"
  value       = module.vpc.network_id
}

output "network_self_link" {
  description = "The self link of the VPC"
  value       = module.vpc.network_self_link
}

output "subnets" {
  description = "The subnets created"
  value       = module.vpc.subnets
}
