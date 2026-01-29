terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "~> 5.0"
        }
        github = {
            source = "integrations/github"
            version = "~> 5.0"
        }
    }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

module "project_config" {
  source = "./module/project-config"
  environment = var.environment
}

provider "google" {
    project = module.project_config.project_id
    region  = "asia-southeast2"
    zone    = "asia-southeast2-a"
}