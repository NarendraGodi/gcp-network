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
