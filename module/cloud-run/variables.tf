variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
}

variable "location" {
  description = "Location for the Cloud Run service"
  type        = string
}

variable "ingress" {
  description = "Ingress configuration for the service"
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"
}

variable "labels" {
  description = "Labels for the Cloud Run service"
  type        = map(string)
  default     = {}
}

variable "template_labels" {
  description = "Labels for the service template"
  type        = map(string)
  default     = {}
}

variable "max_instance_count" {
  description = "Maximum number of instances for scaling"
  type        = number
  default     = null
}

variable "service_account" {
  description = "Service account email for the Cloud Run service"
  type        = string
  default     = null
}

variable "timeout" {
  description = "Timeout for requests"
  type        = string
  default     = "300s"
}

variable "execution_environment" {
  description = "Execution environment (GEN1 or GEN2)"
  type        = string
  default     = "EXECUTION_ENVIRONMENT_GEN2"
}

variable "session_affinity" {
  description = "Enable session affinity"
  type        = bool
  default     = false
}

variable "volumes" {
  description = "List of volumes to mount"
  type = list(object({
    name = string
    gcs = object({
      bucket    = string
      read_only = bool
    })
  }))
  default = []
}

variable "image" {
  description = "Container image URL"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = null
}

variable "cpu_limit" {
  description = "CPU limit"
  type        = string
  default     = "1"
}

variable "memory_limit" {
  description = "Memory limit"
  type        = string
  default     = "512Mi"
}

variable "container_command" {
  description = "Container Command"
  type        = list(string)
}

variable "container_args" {
  description = "Container Args"
  type        = list(string)
}

variable "volume_mounts" {
  description = "List of volume mounts"
  type = list(object({
    name       = string
    mount_path = string
  }))
  default = []
}

variable "env_vars" {
  description = "List of environment variables"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "public_access" {
  description = "Whether to allow public access to the service"
  type        = bool
  default     = false
}

variable "secrets" {
  description = "List of secrets to mount as environment variables"
  type = list(object({
    name        = string # The name of the Env Var inside the container
    secret_name = string # The name of the secret in Secret Manager
    version     = optional(string, "latest") # Version of the secret
  }))
  default = []
}