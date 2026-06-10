# Terraform Configuration & Troubleshooting

## Initialization Errors

### 1. The `-reconfigure` Conflict
**Issue:** Using `terraform init -reconfigure` causes an error when using the HCP Terraform `cloud` block.
**Reason:** The `-reconfigure` flag is intended for legacy backends (S3, GCS). The `cloud` block handles state reconfiguration automatically.
**Fix:** Always use `terraform init` without the `-reconfigure` flag in CI/CD pipelines targeting HCP.

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
