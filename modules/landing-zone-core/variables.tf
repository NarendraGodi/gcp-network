variable "target_env" {
  description = "The environment name (e.g. dev, nonprod, prod)"
  type        = string
}

variable "org_id" {
  description = "The GCP Organization ID"
  type        = string
}

variable "billing_account" {
  description = "The GCP Billing Account ID"
  type        = string
}

variable "network_parent" {
  description = "The parent folder for the network host project (e.g. folders/12345)"
  type        = string
}

variable "region" {
  description = "The primary region for networking"
  type        = string
}

variable "ip_range" {
  description = "The /16 IP supernet for this environment"
  type        = string
}
