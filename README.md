# GCP Landing Zone Phase 2: Network Infrastructure

This repository contains the foundational network infrastructure for the GCP Landing Zone Phase 2. The project is designed with a strict **Separation of Duties** model to distinguish between core infrastructure management and consumer-level resource deployment.

## Project Structure

- **`data/`**: Contains the foundation layer configuration (JSON), defining folder IDs and environment-specific settings.
- **`projects/shared-infra/`**: The core infrastructure workspace.
    - **`foundation_layer.json`**: Environment-specific settings (moved here for HCP Terraform compatibility).
    - **`main.tf`**: Handles project creation and defines the `env_config` logic.
    - **`shared-vpc.tf`**: Manages the Shared VPC Host enablement, Network, and tiered Subnets.
    - **`variables.tf`**: Defines input variables (like `target_env`).
    - **`outputs.tf`**: Exports critical data (Project IDs, VPC names) for downstream use.
- **`GCP Landing Zone Phase 2 Network Plan.pdf`**: The architectural roadmap.

## Dynamic Configuration (env_config)

To keep the code clean and DRY, we use a dynamic lookup pattern in `main.tf`. 

### How it works:
The `local.env_config` variable acts as a "pointer" to the current environment's data:
1. It reads `foundation_layer.json` from the local workspace directory.
2. It selects the block matching `var.target_env` (dev, nonprod, or prod).
3. This allows all other files (like `shared-vpc.tf`) to access environment-specific values using a simple `local.env_config.KEY` syntax.

---

## Design Philosophy: Separation of Duties

The architecture is split into two layers:
1. **Core Infrastructure (This Repo):** Managed by Admins. Handles VPCs, Subnets, and Host Projects.
2. **Consumer Modules (External):** Firewall modules and other service-level resources are managed in separate, student-accessible locations. Students call these modules but do not have visibility into the underlying Landing Zone automation.

## How Modules are Downloaded

Terraform modules are NOT manually cloned. They are automatically managed by the Terraform CLI. The specific piece of code that triggers the download is the **`source`** parameter inside a `module` block.

For example, in `projects/shared-infra/main.tf`:
```hcl
module "network_host_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 17.0"
  # ... other variables
}
```
When you run `terraform init`, Terraform reads this `source`, identifies it as a registry-hosted module, and downloads the required version into the local `.terraform/` directory.

## Multi-Cloud IP Strategy (The "Recognition" Pattern)

To prevent IP overlap and ensure every resource is instantly identifiable across clouds, we use a structured 10.X.Y.Z scheme:

### 1. Cloud Identification (Second Octet)
| Cloud | Second Octet | Range |
| :--- | :--- | :--- |
| **GCP** | **10-19** | `10.10.0.0/14` (Reserved for GCP) |
| **AWS** | **20-29** | `10.20.0.0/14` (Reserved for AWS) |
| **Azure**| **30-39** | `10.30.0.0/14` (Reserved for Azure) |

### 2. Environment Slicing (GCP Example)
Each environment is given a `/16` supernet, which is then sliced into `/24` tiers using the third octet:

| Environment | Supernet | Subnet Slices (3rd Octet) |
| :--- | :--- | :--- |
| **Dev** | `10.10.0.0/16` | `.10` (Web), `.20` (App), `.30` (DB) |
| **Non-Prod**| `10.11.0.0/16` | `.10` (Web), `.20` (App), `.30` (DB) |
| **Prod** | `10.12.0.0/16` | `.10` (Web), `.20` (App), `.30` (DB) |

**Example:** `10.10.10.5` is instantly recognized as: **GCP** -> **Dev** -> **Web Tier**.

## Working Procedure

To manage and deploy this infrastructure, follow these steps:

### 1. Configuration (The "Data" Layer)
Ensure `data/foundation_layer.json` is updated with your target GCP Folder IDs and Org IDs. This file acts as the "source of truth" for the environment hierarchy.

### 2. Initialization
Navigate to the workspace and initialize Terraform. This step downloads the modules and providers.
```bash
cd projects/shared-infra
terraform init
```

### 3. Planning
Always run a plan before applying to preview changes. Use the `target_env` variable to select your environment (e.g., `dev`, `nonprod`, `prod`).
```bash
terraform plan -var="target_env=dev"
```

### 4. Deployment
Once the plan is verified, apply the changes.
```bash
terraform apply -var="target_env=dev"
```

### 5. Maintenance
If you update a module version in the code, you must re-run initialization with the upgrade flag:
```bash
terraform init -upgrade
```

---
*Note: This repository is managed as part of a secure infrastructure rollout. Ensure credentials are never committed to version control.*
