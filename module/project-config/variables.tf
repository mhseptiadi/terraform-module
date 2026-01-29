variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "project_type" {
  description = "Project type (septiadi.com )"
  type        = string
  default     = "septiadi.com"
  validation {
    condition     = contains(["septiadi.com"], var.project_type)
    error_message = "Project type must be one of: septiadi.com"
  }
}
