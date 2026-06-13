# Landing Zone Core Orchestration Module

The Core Orchestration module is the primary engine for setting up a GCP Landing Zone environment. It handles the creation of a Network Host Project, enables Shared VPC host status, and initializes the base networking infrastructure.

## Features

- **Project Creation**: Deploys a dedicated Network Host Project with essential APIs enabled.
- **Shared VPC**: Automatically enables Shared VPC host status on the created project.
- **Environment Isolation**: Uses the `target_env` variable to partition resources across dev, nonprod, and prod.
- **Lifecycle Management**: Includes a `deletion_policy` to prevent accidental project removal in production.

## Usage

```hcl
module "landing_zone" {
  source = "../../modules/landing-zone-core"

  target_env      = "dev"
  org_id          = "1234567890"
  billing_account = "ABCDEF-012345-67890"
  network_parent  = "folders/1122334455"
  region          = "asia-south1"
  ip_range        = "10.10.0.0/16"
  deletion_policy = "DELETE"
}
```

## Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `target_env` | The environment name (e.g. dev, nonprod, prod) | `string` | n/a | yes |
| `org_id` | The GCP Organization ID | `string` | n/a | yes |
| `billing_account` | The GCP Billing Account ID | `string` | n/a | yes |
| `network_parent` | The parent folder for the network host project | `string` | n/a | yes |
| `region` | The primary region for networking | `string` | n/a | yes |
| `ip_range` | The /16 IP supernet for this environment | `string` | n/a | yes |
| `deletion_policy` | Project deletion policy (DELETE or PREVENT) | `string` | `"DELETE"` | no |

## Outputs

| Name | Description |
| :--- | :--- |
| `project_id` | The ID of the created host project |
| `project_number` | The number of the created host project |
| `vpc_name` | The name of the created Shared VPC |
| `subnets` | The subnets created within the Shared VPC |
