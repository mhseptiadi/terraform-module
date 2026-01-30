# Infrastructure Manager

This Terraform configuration manages Google Cloud Run deployments for the Septiadi Site infrastructure.

## 📁 Project Structure

```
infrastructure-manager/
├── main.tf                 # Root: provider config, required_providers, project_config module
├── import.tf               # Import blocks (e.g. existing Cloud Run → Terraform state)
├── github-secrets.tf       # GitHub Actions secrets (Workload Identity, Infra Manager token)
├── ai-instruct.yaml        # AI / editor instructions
├── .gitignore
├── .terraform.lock.hcl
│
├── module/
│   ├── cloud-run/          # Reusable Cloud Run (v2) module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── project-config/     # Project/environment config (project ID, service account)
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── environments/
│   └── prod/
│       └── septiadi_site/
│           ├── project-config.tf    # Instantiates project-config as "septiadi_site"
│           ├── gcp-infra-config.tf  # GCP infra (Secret Manager, Cloud Build GitHub connection)
│           ├── .terraform.lock.hcl
│           └── septiadi.com/        # Cloud Run service: septiadi-com
│               ├── main.tf          # cloud-run module + image_url variable
│               ├── variables.tf
│               ├── backend.__       # GCS backend (rename to backend.tf to use)
│               └── .terraform.lock.hcl
│
├── gcloud.cheatsheet       # gcloud / GCP CLI notes
├── gcp-service-account-setup.sh
├── workload-identity-federation-setup.sh
├── service-account-role-setup.sh
└── trigger_deployment.sh
```

**Terraform working directories**

- **Root** (`infrastructure-manager/`): provider setup, `project_config` module, GitHub secrets. Run `terraform init` / `plan` / `apply` from here for root-level resources.
- **Service** (`environments/prod/septiadi_site/septiadi.com/`): Cloud Run service. Uses GCS backend; run `terraform init` / `plan` / `apply` from this directory to manage the septiadi.com service. Ensure backend config is active (e.g. rename `backend.__` to `backend.tf` or use `-backend-config`).

**Importing existing resources:** Use `import.tf` (or equivalent `import` blocks) to bring existing GCP resources (e.g. Cloud Run) into Terraform state; then run `terraform plan` to align config with code.

## 🚀 Prerequisites

1. **Terraform** installed (version 1.0+)
2. **Google Cloud SDK** installed and configured
3. **GCP Service Account** with appropriate permissions:
   - Cloud Run Admin
   - Service Account User
   - Secret Manager Admin (for secrets)
   - Storage Admin (for GCS volumes and state)
4. **GCS Bucket** for Terraform state (e.g., `tf-state-septiadi_site-dev`)

## 📋 Setup

1. **Clone or navigate to the repository:**
   ```bash
   cd infrastructure-manager
   ```

2. **Initialize Terraform in root (for provider configuration):**
   ```bash
   terraform init
   ```

3. **Set environment variable (optional, defaults to "prod"):**
   ```bash
   # For Windows PowerShell
   $env:TF_VAR_environment = "prod"
   
   # For Windows CMD
   set TF_VAR_environment=prod
   
   # For Linux/Mac
   export TF_VAR_environment=prod
   ```

## 🎯 Usage

### Deploying the Septiadi.com service

1. **Use the service directory** (backend is GCS; ensure `backend.tf` is present, e.g. by renaming `backend.__`):
   ```bash
   cd environments/prod/septiadi_site/septiadi.com
   ```

2. **Initialize Terraform (first time only):**
   ```bash
   terraform init
   ```

3. **Plan your deployment:**
   ```bash
   terraform plan -var="image_url=us-central1-docker.pkg.dev/PROJECT_ID/cloud-run-source-deploy/septiadi-com:latest"
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply -var="image_url=us-central1-docker.pkg.dev/PROJECT_ID/cloud-run-source-deploy/septiadi-com:latest"
   ```

### Using Root Directory (Provider Configuration Only)

The root `main.tf` is used for provider configuration. To set the environment:

```bash
# Set environment variable
export TF_VAR_environment=prod  # or dev, staging

# Initialize and validate
terraform init
terraform validate
```

### Managing GitHub Actions Secrets

The `github-secrets.tf` file manages GitHub Actions secrets for other repositories. This allows you to inject GCP Workload Identity Provider and Infra Manager Token secrets into multiple repositories.

**Prerequisites:**
- GitHub Personal Access Token with `repo` and `admin:repo_hook` permissions
- GitHub organization or username

**Usage:**

1. **Set required variables:**
   ```bash
   export TF_VAR_github_token="your_github_token"
   export TF_VAR_github_owner="your-org-or-username"
   export TF_VAR_infra_manager_token="your-infra-manager-token"
   ```

2. **Configure repositories (optional, using terraform.tfvars):**
   ```hcl
   github_repositories = {
     product = {
       workload_identity_provider = "projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/product-pool/providers/product-provider"
     }
     inventory = {
       workload_identity_provider = "projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/inventory-pool/providers/inventory-provider"
     }
   }
   ```

3. **Apply the configuration:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

**What it does:**
- Injects `GCP_WORKLOAD_IDENTITY_PROVIDER` secret (unique per repository)
- Injects `INFRA_MANAGER_TOKEN` secret (shared across all repositories)

## 📦 Cloud Run Module

The `module/cloud-run` is a reusable module for deploying Google Cloud Run services.

### Module Variables

| Variable | Type | Description | Required |
|----------|------|-------------|----------|
| `service_name` | string | Name of the Cloud Run service | Yes |
| `location` | string | GCP region for deployment | Yes |
| `image` | string | Container image URL | Yes |
| `container_port` | number | Container port | No |
| `ingress` | string | Ingress configuration | No (default: "INGRESS_TRAFFIC_ALL") |
| `max_instance_count` | number | Maximum instances for scaling | No |
| `cpu_limit` | string | CPU limit (e.g., "1", "2") | No (default: "1") |
| `memory_limit` | string | Memory limit (e.g., "512Mi", "1Gi") | No (default: "512Mi") |
| `service_account` | string | Service account email | No |
| `timeout` | string | Request timeout | No (default: "300s") |
| `execution_environment` | string | Execution environment (GEN1/GEN2) | No (default: "EXECUTION_ENVIRONMENT_GEN2") |
| `session_affinity` | bool | Enable session affinity | No (default: false) |
| `env_vars` | list(object) | Environment variables | No (default: []) |
| `secrets` | list(object) | Secret Manager secrets | No (default: []) |
| `volumes` | list(object) | GCS volumes to mount | No (default: []) |
| `volume_mounts` | list(object) | Volume mount configurations | No (default: []) |
| `labels` | map(string) | Service labels | No (default: {}) |
| `template_labels` | map(string) | Template labels | No (default: {}) |
| `public_access` | bool | Allow public access | No (default: false) |

### Example: Adding a New Service

Create a new directory under `environments/prod/septiadi_site/` (e.g., `my-service/`) with:

**backend.tf** (or copy from `septiadi.com/backend.__` and rename):
```hcl
terraform {
  backend "gcs" {
    bucket = "tf-state-septiadi_site-dev"
    prefix = "my-service"
  }
}
```

**main.tf:**
```hcl
module "my_service" {
  source = "../../../../module/cloud-run"

  service_name   = "my-service"
  location       = "us-central1"   # or asia-southeast2
  service_account = "PROJECT_NUMBER-compute@developer.gserviceaccount.com"  # or from project-config output

  ingress = "INGRESS_TRAFFIC_ALL"
  labels  = { "environment" = "prod", "service" = "my-service" }
  template_labels = { "environment" = "prod", "service" = "my-service" }

  max_instance_count    = 3
  timeout               = "300s"
  execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
  session_affinity      = false

  image          = var.image_url
  container_port = 8080
  cpu_limit      = "1000m"
  memory_limit   = "128Mi"

  env_vars = [
    { name = "NODE_ENV", value = "production" }
  ]

  public_access = true
}
```

**variables.tf:**
```hcl
variable "image_url" {
  description = "The full container image URL"
  type        = string
}
```

Run `terraform init` and `terraform plan` / `apply` from the new service directory.

## 🔧 Common Terraform Commands

### Initialization
```bash
terraform init                    # Initialize Terraform
terraform init -upgrade          # Upgrade providers
```

### Planning
```bash
terraform plan                    # Show execution plan
terraform plan -out=tfplan       # Save plan to file
terraform plan -var="image_url=..." # Plan with variables
```

### Applying
```bash
terraform apply                   # Apply changes
terraform apply -auto-approve    # Apply without confirmation
terraform apply -var="image_url=..." # Apply with variables
terraform apply tfplan           # Apply saved plan
```

### State Management
```bash
terraform state list              # List all resources
terraform state show module.xxx  # Show resource details
terraform refresh                 # Refresh state
```

### Destruction
```bash
terraform destroy                 # Destroy all resources
terraform destroy -target=module.xxx # Destroy specific resource
```

## 🔑 Project Configuration

The `module/project-config` module holds environment-specific GCP settings:
- **Project ID** and **Service Account** per environment (dev, staging, prod)
- **Project types**: e.g. `septiadi_site` (wired in `environments/prod/septiadi_site/project-config.tf`)

**Where it’s used:**
- **Root** (`main.tf`): `module "project_config"` — used by the root Google provider (`project = module.project_config.project_id`).
- **Environment** (`environments/prod/septiadi_site/project-config.tf`): `module "septiadi_site"` — use when running Terraform from that directory.

### Module outputs

- `project_id` — GCP project ID for the selected environment  
- `service_account` — GCP service account email  
- `project_type` — project type string  

From root: `module.project_config.project_id`, `module.project_config.service_account`  
From `septiadi_site`: `module.septiadi_site.project_id`, `module.septiadi_site.service_account`

## 🔐 Security Notes

1. **State Files**: Uses GCS backend for remote state management
   - State bucket: `tf-state-septiadi_site-dev`
   - Each service has its own prefix for state isolation
2. **Secrets**: Uses Google Secret Manager for sensitive environment variables
   - Secrets are referenced in the Cloud Run module via the `secrets` variable
3. **IAM**: Review and restrict service account permissions
4. **Volumes**: GCS volumes are mounted read-only by default for security

## 📝 Best Practices

1. **Always run `terraform plan` before `terraform apply`**
2. **Navigate to the specific service directory** before running terraform commands
3. **Use variables for image URLs** instead of hardcoding
4. **Keep module versions consistent** across environments
5. **Use project-config module outputs** for project IDs instead of hardcoding
6. **Test in dev environment first** before deploying to production
7. **Document any custom configurations**

## 🐛 Troubleshooting

### Module Not Found
```bash
# Re-initialize Terraform
terraform init
```

### Authentication Errors
- Verify you're authenticated with GCP: `gcloud auth application-default login`
- Ensure service account has required permissions
- Check that you're using the correct project ID

### State Lock Issues
```bash
# If state is locked, check for running Terraform processes
# Or use force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

### Backend configuration errors
- Ensure the GCS bucket exists: `gsutil ls gs://tf-state-septiadi_site-dev`
- Verify you have permissions to read/write to the bucket
- Service dir uses a GCS backend: copy or rename `backend.__` to `backend.tf` in `environments/prod/septiadi_site/septiadi.com/` if Terraform doesn’t pick it up

## 📚 Additional Resources

- [Terraform Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/language/best-practices/index.html)
- [Terraform GCS Backend](https://www.terraform.io/docs/language/settings/backends/gcs.html)

## 📖 Quick Reference

### Common Workflows

**Deploy septiadi.com service** (run from service directory; ensure backend is configured, e.g. `backend.tf` or `backend.__`):
```bash
cd environments/prod/septiadi_site/septiadi.com
terraform init
terraform plan -var="image_url=us-central1-docker.pkg.dev/PROJECT_ID/cloud-run-source-deploy/septiadi-com:latest"
terraform apply -var="image_url=us-central1-docker.pkg.dev/PROJECT_ID/cloud-run-source-deploy/septiadi-com:latest"
```

**Update septiadi.com (new image):**
```bash
cd environments/prod/septiadi_site/septiadi.com
terraform plan -var="image_url=NEW_IMAGE_URL"
terraform apply -var="image_url=NEW_IMAGE_URL"
```

**Check what will be changed:**
```bash
cd environments/prod/septiadi_site/septiadi.com
terraform plan -var="image_url=IMAGE_URL"
```

**Inject GitHub secrets to repositories:**
```bash
# From root directory
export TF_VAR_github_token="your_token"
export TF_VAR_github_owner="your-org"
export TF_VAR_infra_manager_token="your_token"
terraform init
terraform plan -target=github_actions_secret.iam_provider -target=github_actions_secret.infra_manager_token
terraform apply -target=github_actions_secret.iam_provider -target=github_actions_secret.infra_manager_token
```

---

**Note**: Always test changes in a development environment before applying to production. Make sure you're in the correct service directory before running terraform commands.
