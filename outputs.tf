output "primary_connection" {
  description = "Primary connection data."
  value       = equinix_fabric_connection.primary
}

output "secondary_connection" {
  description = "Secondary connection data."
  value       = try(equinix_fabric_connection.secondary, null)
}
