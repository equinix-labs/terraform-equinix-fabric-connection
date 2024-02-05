output "fabric_connection_id" {
  description = "Primary connection id."
  value       = module.equinix_fabric_connection.primary_connection.id
}

output "fabric_connection_status" {
  description = "Primary connection equinix status."
  value       = module.equinix_fabric_connection.primary_connection.status
}

output "fabric_connection_provider_status" {
  description = "Primary connection provider status."
  value       = module.equinix_fabric_connection.primary_connection.provider_status
}
