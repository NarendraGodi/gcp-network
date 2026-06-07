output "project_id" {
  value       = module.network_host_project.project_id
  description = "The ID of the created networking host project (to be used by upstream app projects)"
}

output "project_number" {
  value       = module.network_host_project.project_number
  description = "The project number of the created networking host project"
}
