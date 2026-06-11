# GCP Landing Zone Phase 2: Network Infrastructure

This repository contains the foundational network infrastructure for the GCP Landing Zone Phase 2. The project is designed with a strict **Separation of Duties** model to distinguish between core infrastructure management and consumer-level resource deployment.

## Mandatory Prerequisites (Manual Setup)

Before running this automation for the first time, the following manual steps **must** be completed. Failure to do so will result in API or Path errors.

### 1. GCP: Enable Admin APIs
Terraform requires these APIs in your Root/Seed project (e.g., `fifth-honor-498711-k7`) to manage the organization:
- **Cloud Billing API**: To link projects to your billing account.
- **Cloud Resource Manager API**: To create and manage projects and folders.
- **Identity and Access Management (IAM) API**: To create service accounts for the new projects.

**Action:** Go to **APIs & Services > Library**, search for each, and click **Enable**.

### 2. HCP Terraform: Set Working Directory
Because this is a monorepo with a shared `/modules` folder, HCP Terraform must be told where the project starts.
- **Where:** In each HCP Workspace > **Settings > General**.
- **Action:** Set **Terraform Working Directory** to `projects/shared-infra`.
- **Why:** This ensures the remote runner can see the `../../modules` directory.

### 3. GCP: Identity & Access
Ensure your "Grand Architect" Service Account (e.g., `iac-landing-zone-admin@...`) has the following **Organization-level** roles assigned:
- **Project Creator**: To create the environment host projects.
- **Billing User**: To link projects to billing.
- **Folder Admin**: To organize projects into folders.
- **Compute Network Admin**: To manage Shared VPCs.

See the [HCP Setup Guide](docs/knowledge-base/hcp.md) for full IAM details.

## Project Structure

- **`modules/landing-zone-core/`**: The **Reusable Engine**. This is a stateless module that creates projects, VPCs, and subnets. It is designed to be portable across different GCP Organizations.
- **`projects/shared-infra/`**: The **Consumer Workspace**. This is where we "instantiate" the Landing Zone for your specific organization using `foundation_layer.json`.
- **`data/`**: (Deprecated - use projects/shared-infra/foundation_layer.json) Legacy configuration storage.
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

## Knowledge Base & Troubleshooting

For detailed setup instructions and lessons learned during the development of this Landing Zone, please refer to the following:

- **[HCP Terraform Setup](docs/knowledge-base/hcp.md)**: Workspace naming, tagging, and execution modes.
- **[GitHub Actions CI/CD](docs/knowledge-base/github.md)**: Branching strategy, secrets, and deployment flow.
- **[Terraform Troubleshooting](docs/knowledge-base/terraform.md)**: Common errors (like `-reconfigure`), architectural patterns, and monorepo pathing.
