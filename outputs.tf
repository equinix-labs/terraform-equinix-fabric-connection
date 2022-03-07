output "primary_connection_uuid" {
  description = "Unique identifier of the connection."
  value       = equinix_ecx_l2_connection.this.uuid
}

output "primary_connection_name" {
  description = "Name of the connection."
  value       = equinix_ecx_l2_connection.this.name
}

output "primary_connection_status" {
  description = "Connection provisioning status."
  value       = equinix_ecx_l2_connection.this.status
}

output "primary_connection_provider_status" {
  description = "Connection provisioning provider status."
  value       = equinix_ecx_l2_connection.this.provider_status
}

output "primary_connection_speed" {
  description = "Connection speed."
  value       = equinix_ecx_l2_connection.this.speed
}

output "primary_connection_speed_unit" {
  description = "Connection speed unit."
  value       = equinix_ecx_l2_connection.this.speed_unit
}

output "primary_connection_seller_metro" {
  description = "Connection seller metro code."
  value       = equinix_ecx_l2_connection.this.seller_metro_code
}

output "primary_connection_seller_region" {
  description = "Connection seller region."
  value       = equinix_ecx_l2_connection.this.seller_region
}

output "secondary_connection_uuid" {
  description = "Unique identifier of the secondary connection."
  value       =  try(equinix_ecx_l2_connection.this.secondary_connection.0.uuid, null)
}

output "secondary_connection_name" {
  description = "Name of the secondary connection."
  value       = try(equinix_ecx_l2_connection.this.secondary_connection.0.name, null)
}

output "secondary_connection_status" {
  description = "Secondary connection provisioning status."
  value       = try(equinix_ecx_l2_connection.this.secondary_connection.0.status, null)
}

output "secondary_connection_provider_status" {
  description = "Secondary connection provisioning provider status."
  value       = try(equinix_ecx_l2_connection.this.secondary_connection.0.provider_status, null)
}

output "secondary_connection_speed" {
  description = "Secondary connection speed."
  value       = try(equinix_ecx_l2_connection.this.secondary_connection.0.speed, null)
}

output "secondary_connection_speed_unit" {
  description = "Secondary connection speed unit."
  value       = try(equinix_ecx_l2_connection.this.secondary_connection.0.speed_unit, null)
}

output "secondary_connection_seller_metro" {
  description = "Secondary connection seller metro code."
  value       = try(equinix_ecx_l2_connection.this.secondary_connection.0.seller_metro_code, null)
}

output "secondary_connection_seller_region" {
  description = "Connection seller region."
  value       = try(equinix_ecx_l2_connection.this.secondary_connection.0.seller_region, null)
}
