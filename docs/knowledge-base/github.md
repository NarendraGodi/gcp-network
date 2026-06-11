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

## Promotion & Branching Rules

To ensure a stable and predictable infrastructure, follow this "Promotion" flow:

### 1. Development (The Sandbox)
- **Action:** Create a feature branch from `dev`.
- **Validation:** Pushing to the feature branch triggers a **Plan** against the Dev environment.
- **Merge:** Merge the feature branch into `dev`.
- **Result:** Triggers **Apply** in Dev + **Plan** in Non-Prod.

### 2. Staging (Non-Prod)
- **Action:** Once Dev is stable and the "Plan Forward" for Non-Prod looks green, merge `dev` into `nonprod`.
- **Result:** Triggers **Apply** in Non-Prod + **Plan** in Prod.

### 3. Production (The Gold Standard)
- **Action:** Once Non-Prod is verified, merge `nonprod` into `main`.
- **Result:** Triggers **Apply** in Prod.

## Manual Promotion Commands
If you are moving entire branches for the first time:
```bash
# To Non-Prod
git checkout nonprod
git merge dev
git push origin nonprod

# To Prod
git checkout main
git merge nonprod
git push origin main
```

## Key GitHub Variables
- `TF_WORKSPACE`: Set dynamically in the workflow to match the full HCP workspace name.
- `ENV`: Used to pass the `target_env` variable to Terraform.
