resource "digitalocean_droplet" "default" {
  name   = var.vm_name
  region = var.region
  size   = var.size
  image  = var.image

  tags   = var.tags
  backups = var.backups
  monitoring = var.monitoring
  ipv6   = var.ipv6

  ssh_keys = var.ssh_keys
  vpc_uuid = var.vpc_uuid
  user_data = var.user_data

  droplet_agent   = var.droplet_agent
  graceful_shutdown = var.graceful_shutdown

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      # user_data, # uncomment if you change cloud-init after creation
    ]
  }
}
