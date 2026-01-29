output "project_id" {
  description = "GCP Project ID"
  value       = local.project_config[var.environment].project_id
}

output "service_account" {
  description = "GCP Service Account email"
  value       = local.project_config[var.environment].service_account
}

output "project_type" {
  description = "Project type (septiadi.com)"
  value       = var.project_type
}
