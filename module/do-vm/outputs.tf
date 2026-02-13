output "vm_name" {
  description = "Name of the DigitalOcean Droplet"
  value       = digitalocean_droplet.default.name
}

output "vm_id" {
  description = "ID of the DigitalOcean Droplet"
  value       = digitalocean_droplet.default.id
}

output "vm_region" {
  description = "Region of the DigitalOcean Droplet"
  value       = digitalocean_droplet.default.region
}

output "ipv4_address" {
  description = "Public IPv4 address of the Droplet"
  value       = digitalocean_droplet.default.ipv4_address
}

output "ipv4_address_private" {
  description = "Private IPv4 address of the Droplet"
  value       = digitalocean_droplet.default.ipv4_address_private
}

output "ipv6_address" {
  description = "IPv6 address of the Droplet (if enabled)"
  value       = digitalocean_droplet.default.ipv6_address
}
