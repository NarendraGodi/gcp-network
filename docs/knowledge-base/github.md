# GitHub Actions & CI/CD Logic

## Secrets Requirements
To enable the pipeline, the following GitHub Secrets must be configured:
- `TF_API_TOKEN`: The HCP Terraform User API Token (atlasv1).

## Branch-to-Environment Mapping
The workflow automatically detects the branch and maps it to the corresponding environment:
- `main` branch -> **Prod**
- `nonprod` branch -> **Non-Prod**
- `dev` branch -> **Dev**
- All other branches -> **Dev (Plan only)**

## Deployment Flow
1. **Push to Feature Branch:** Triggers a `terraform plan` against the Dev environment.
2. **Merge to Dev:** Triggers `terraform apply` on Dev + `terraform plan` on Non-Prod.
3. **Merge to Non-Prod:** Triggers `terraform apply` on Non-Prod + `terraform plan` on Prod.
4. **Merge to Main:** Triggers `terraform apply` on Prod.

## Key GitHub Variables
- `TF_WORKSPACE`: Set dynamically in the workflow to match the full HCP workspace name.
- `ENV`: Used to pass the `target_env` variable to Terraform.
