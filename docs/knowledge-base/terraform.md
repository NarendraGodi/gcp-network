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

### 2. Cloud Resource Manager API Disabled
**Issue:** `Error 403: Cloud Resource Manager API has not been used in project ... before or it is disabled.`
**Reason:** Terraform requires this API to create and manage the hierarchy (Projects and Folders) in your organization.
**The "403 Ambiguity" Note:** In GCP, a 403 error can be confusing. It often points to a missing `projectCreator` role, but it is **also** the default error when the API itself is disabled. Always check the API status before debugging IAM permissions.
**Fix:** Same as the Billing API; enable it in your Root/Seed project (`fifth-honor-498711-k7`) via the API Library.

### 3. IAM API Disabled
**Issue:** `Error: Error creating service account: googleapi: Error 403: Identity and Access Management (IAM) API has not been used in project ... before or it is disabled.`
**Reason:** Terraform needs to create a Project-level Service Account to manage the new host project. This requires the IAM API to be active in the project where the code is running.
**Fix:** Enable the **Identity and Access Management (IAM) API** in your Root/Seed project via the API Library.

### 4. Cloud Billing Quota Exceeded
**Issue:** `Error 400: Precondition check failed ... Cloud billing quota exceeded`
**Reason:** New GCP accounts or those on Free Trials often have a limit on how many projects can be linked to a billing account simultaneously (typically 3 to 5 projects).
**Fix:** 
1. **Request Increase:** Visit the [Google Billing Quota Request](https://support.google.com/code/contact/billing_quota_increase) form. It usually takes 24-48 hours to process.
2. **Clean Up:** Check the **Resource Manager** and delete any old or unused test projects to free up "quota slots."

## Operational Settings

### 1. Project Deletion Policy
To support the iterative "Create/Destroy" needs of the stabilization phase, we have added a `deletion_policy` variable.
- **`DELETE` (Current Default):** Allows Terraform to fully destroy projects. Useful for testing and fixing quota issues.
- **`PREVENT` (Recommended for Prod):** Prevents accidental project deletion.
- **How to use:** In HCP Terraform, you can set the variable `deletion_policy` to `PREVENT` once your landing zone is finalized.

**Standardization:** All three mandatory APIs (Billing, Resource Manager, IAM) have been added to the `activate_apis` list in the core module.

### 4. Unreadable Module Directory (HCP Remote Execution)
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
