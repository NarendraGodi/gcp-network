variable "project_id" {
  description = "The ID of the project where the VPC will be created"
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "region" {
  description = "The region where subnets will be created"
  type        = string
}

variable "ip_range" {
  description = "The /16 IP supernet for this environment"
  type        = string
}

variable "target_env" {
  description = "The environment name (e.g. dev, nonprod, prod)"
  type        = string
}

variable "subnets" {
  description = "Map of subnet configurations. The key is the subnet suffix (e.g., 'web'), and the value contains the CIDR offset and description."
  type = map(object({
    offset      = number
    description = string
  }))
  default = {
    web = { offset = 10, description = "Web Tier" }
    app = { offset = 20, description = "Application Tier" }
    db  = { offset = 30, description = "Database Tier" }
  }
}
