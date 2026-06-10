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
- Set **Execution Mode** to **Local**.
- This allows GitHub Actions to perform the computation while HCP Terraform acts as the secure state storage and locking mechanism.

### 4. Authentication
Generate a **User API Token** (atlasv1 format) from your User Settings > Tokens to be used in GitHub Secrets.
