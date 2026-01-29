variable "github_token" {
  description = "GitHub personal access token with repo and admin:repo_hook permissions"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub organization or username"
  type        = string
  default     = ""  # Set your GitHub org/username
}

variable "infra_manager_token" {
  description = "Infra Manager Token (shared across all repositories)"
  type        = string
  sensitive   = true
  default     = ""  # Set your INFRA_MANAGER_TOKEN
}

variable "github_repositories" {
  description = "Map of GitHub repository names to their Workload Identity Provider paths"
  type = map(object({
    workload_identity_provider = string
  }))
  default = {
    product = {
      workload_identity_provider = "projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/..."
    }
    inventory = {
      workload_identity_provider = "projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/..."
    }
    kds = {
      workload_identity_provider = "projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/..."
    }
  }
}

provider "github" {
  owner = var.github_owner
  token = var.github_token
}

resource "github_actions_secret" "iam_provider" {
  for_each      = var.github_repositories
  repository    = each.key
  secret_name   = "GCP_WORKLOAD_IDENTITY_PROVIDER"
  plaintext_value = each.value.workload_identity_provider
}

resource "github_actions_secret" "infra_manager_token" {
  for_each      = var.github_repositories
  repository    = each.key
  secret_name   = "INFRA_MANAGER_TOKEN"
  plaintext_value = var.infra_manager_token
}
