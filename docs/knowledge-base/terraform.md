# Terraform Configuration & Troubleshooting

## Initialization Errors

### 1. The `-reconfigure` Conflict
**Issue:** Using `terraform init -reconfigure` causes an error when using the HCP Terraform `cloud` block.
**Reason:** The `-reconfigure` flag is intended for legacy backends (S3, GCS). The `cloud` block handles state reconfiguration automatically.
**Fix:** Always use `terraform init` without the `-reconfigure` flag in CI/CD pipelines targeting HCP.

### 2. Required Token Not Found (Authentication)
**Issue:** `Error: Required token could not be found` during `terraform init` in GitHub Actions.
**Reason:** The `setup-terraform` action may not always correctly propagate the `cli_config_token` to the underlying shell environment in all scenarios.
**Fix:** Explicitly set the environment variable `TF_TOKEN_app_terraform_io` in the GitHub Actions job. Terraform looks for this specific variable name (formatted as `TF_TOKEN_<hostname>` with underscores) to authenticate against HCP Terraform.

## Deployment Errors

### 1. Cloud Billing API Disabled
**Issue:** `Error: failed pre-requisites: failed to check permissions on billing account ... googleapi: Error 403: Cloud Billing API has not been used in project ... before or it is disabled.`
**Reason:** When Terraform attempts to create a project and link it to a billing account, it must use the Cloud Billing API. This API must be enabled in the project where the Service Account (the caller) is hosted.
**Fix:** 
1. Go to the project hosting the Service Account (e.g., `fifth-honor-498711-k7`).
2. Navigate to **APIs & Services > Library**.
3. Search for **"Cloud Billing API"** and click **Enable**.
4. Wait a few minutes for propagation and retry the deployment.

**Standardization:** To prevent this issue in downstream projects, the `cloudbilling.googleapis.com` API has been added to the `activate_apis` list in `main.tf`.

### 2. Unreadable Module Directory (HCP Remote Execution)
**Issue:** `Error: Unreadable module directory ... Unable to evaluate directory symlink: lstat ../../modules: no such file or directory`
**Reason:** In HCP Terraform **Remote Execution** mode, only the files within the current working directory are uploaded by default. If your project uses local modules located outside its own folder (e.g., `../../modules`), the remote runner cannot find them.
**Fixes:**
- **Option A (Recommended):** In HCP Workspace Settings > General, set the **Terraform Working Directory** to `projects/shared-infra`. This tells HCP to upload the entire repository root, making the `/modules` folder accessible.
- **Option B:** Switch the Workspace **Execution Mode** to **Local**. This runs the code on the GitHub runner (which has all files) and only sends state to HCP.

## Architectural Patterns

### 1. Workspace Discovery (Tags vs Prefix)
- **Deprecated:** `workspaces { prefix = "..." }`
- **Modern:** `workspaces { tags = ["..."] }`
- **Key Difference:** Using tags is more secure as it requires manual labeling in the UI, preventing accidental workspace creation from typos in CI/CD.

### 2. Relative Paths in Monorepos
When using HCP Terraform (especially with remote execution), only files within the active `working-directory` are uploaded to the runner.
- **Problem:** Files like `../../data/config.json` will not be found.
- **Solution:** Place all required configuration files (like `foundation_layer.json`) inside the project folder itself or use a data-loading strategy that ensures they are included in the build context.

### 3. Shared VPC Host Logic
In this project, we explicitly use `google_compute_shared_vpc_host_project` to convert a standard project into a network hub. This must be done **before** subnets can be shared with service projects.

## Future Roadmap & Security Hardening

### 1. Transition to Workload Identity Federation (WIF)
**Objective:** Replace static JSON Service Account keys with short-lived, keyless authentication.
- **Why:** To align with Google's "Secure by Default" standards and eliminate the risk of compromised static keys.
- **Action:** 
    - Configure a Workload Identity Pool and Provider in GCP.
    - Establish a trust relationship between HCP Terraform (using its OIDC provider) and the GCP Organization.
    - Update HCP Workspaces to use `TFC_GCP_PROVIDER_AUTH` instead of `GOOGLE_CREDENTIALS`.
