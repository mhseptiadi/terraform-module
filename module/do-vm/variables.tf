variable "vm_name" {
  description = "Name of the DigitalOcean Droplet (VM)"
  type        = string
}

variable "region" {
  description = "Region where the Droplet will be created (e.g. nyc2, sgp1)"
  type        = string
}

variable "size" {
  description = "Droplet size slug (e.g. s-1vcpu-1gb, s-2vcpu-2gb)"
  type        = string
}

variable "image" {
  description = "Droplet image ID or slug (e.g. ubuntu-22-04-x64)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the Droplet"
  type        = list(string)
  default     = []
}

variable "backups" {
  description = "Whether to enable backups"
  type        = bool
  default     = false
}

variable "monitoring" {
  description = "Whether to install the monitoring agent"
  type        = bool
  default     = false
}

variable "ipv6" {
  description = "Whether to enable IPv6"
  type        = bool
  default     = false
}

variable "ssh_keys" {
  description = "List of SSH key IDs or fingerprints to enable on the Droplet"
  type        = list(string)
  default     = []
}

variable "vpc_uuid" {
  description = "ID of the VPC where the Droplet will be located"
  type        = string
  default     = null
}

variable "user_data" {
  description = "Cloud-init user data script to run on first boot"
  type        = string
  default     = null
}

variable "droplet_agent" {
  description = "Whether to install the DigitalOcean agent for web console access"
  type        = bool
  default     = true
}

variable "graceful_shutdown" {
  description = "Whether to gracefully shut down the droplet before deletion"
  type        = bool
  default     = true
}
