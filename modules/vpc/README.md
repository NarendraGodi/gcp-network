# VPC Standalone Utility Module

This module provides a standardized way to create a VPC network and subnets within a GCP project. It is designed to be reusable across different projects while maintaining the landing zone's IP scheme and naming conventions.

## Features

- Creates a VPC network with global routing.
- Dynamically creates subnets based on a provided map of tiers and CIDR offsets.
- Standardizes resource naming (e.g., `sb-<env>-<region>-<tier>`).

## Usage

```hcl
module "vpc" {
  source = "git@github.com:NarendraGodi/gcp-network.git//modules/vpc?ref=dev"

  project_id   = "my-project-id"
  network_name = "vpc-my-app-shared"
  region       = "asia-south1"
  ip_range     = "10.20.0.0/16"
  target_env   = "dev"

  # Optional: Define custom subnet tiers
  subnets = {
    web = { offset = 10, description = "Web Tier" }
    app = { offset = 20, description = "Application Tier" }
    db  = { offset = 30, description = "Database Tier" }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `project_id` | The ID of the project where the VPC will be created | `string` | n/a | yes |
| `network_name` | The name of the VPC network | `string` | n/a | yes |
| `region` | The region where subnets will be created | `string` | n/a | yes |
| `ip_range` | The /16 IP supernet for this environment | `string` | n/a | yes |
| `target_env` | The environment name (e.g. dev, nonprod, prod) | `string` | n/a | yes |
| `subnets` | Map of subnet configurations (key: suffix, value: offset/description) | `map` | (Standard Tiers) | no |

## Outputs

| Name | Description |
| :--- | :--- |
| `network_name` | The name of the created VPC |
| `network_id` | The ID of the created VPC |
| `network_self_link` | The self link of the created VPC |
| `subnets` | The subnets created within the VPC |
