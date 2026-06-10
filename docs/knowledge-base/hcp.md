# HCP Terraform Setup & Configuration

## Workspace Management
For this Landing Zone, we use a **CLI-Driven Workflow** with **Local Execution**.

### 1. Naming Convention
Workspaces must follow the pattern: `gcp-networking-<env>`
- `gcp-networking-dev`
- `gcp-networking-nonprod`
- `gcp-networking-prod`

### 2. Tagging (The "Handshake")
Every workspace MUST be tagged with the label **`networking`**. 
- **Why?** The Terraform `cloud` block in our code uses `tags = ["networking"]` to discover valid target workspaces. This is a security guardrail to prevent cross-project deployments.

### 3. Execution Mode
In the Workspace Settings > General:
- Set **Execution Mode** to **Remote** (recommended for professional setups) or **Local**.
- If using **Remote**, HCP Terraform manages the deployment. If using **Local**, GitHub Actions manages it.

### 4. Authentication
#### User API Token
Generate a **User API Token** (atlasv1 format) from your User Settings > Tokens to be used in GitHub Secrets.

#### GCP Service Account (The "Grand Architect")
Since Terraform needs to create projects and manage billing across the organization, we use a dedicated identity:

- **Service Account Email:** `iac-landing-zone-admin@fifth-honor-498711-k7.iam.gserviceaccount.com`
- **Host Project:** `fifth-honor-498711-k7` (Root/Billing Project)

##### Mandatory IAM Roles (Assigned at Organization Level):
For the automation to work, the following roles must be granted to the email above at the **Organization** level (narendragodi.cv):
1. **Project Creator** (`roles/resourcemanager.projectCreator`): To create host projects.
2. **Billing User** (`roles/billing.user`): To associate projects with the billing account.
3. **Folder Admin** (`roles/resourcemanager.folderAdmin`): To move projects into the Dev/Non-Prod/Prod folder hierarchy.
4. **Compute Network Admin** (`roles/compute.networkAdmin`): To manage Shared VPCs and subnets.

##### HCP Configuration:
1. **Generate Key:** Create a JSON key for the "Grand Architect" SA in the GCP Console.
2. **Centralized Variables (Variable Sets):** 
   - Instead of adding the key to each workspace manually, we use an HCP **Variable Set** named `GCP-Landing-Zone-Credentials`.
   - **Environment Variable:** `GOOGLE_CREDENTIALS` (Sensitive: Yes).
   - **Scope:** This variable set is applied to `gcp-networking-dev`, `gcp-networking-nonprod`, and `gcp-networking-prod`.
   - **Benefit:** Allows for single-point rotation of credentials across the entire environment chain.

##### Post-Setup Security Hardening:
Once the JSON key is generated and stored in HCP Terraform, it is a best practice to:
1. **Re-enable Org Policy:** Set the Organization Policy `iam.disableServiceAccountKeyCreation` back to **Enforced (On)**.
2. **Locking the Door:** This prevents the accidental creation of additional persistent keys while allowing the existing "Grand Architect" key to continue functioning.
