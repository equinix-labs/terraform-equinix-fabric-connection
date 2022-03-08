output "primary_connection" {
  description = "Primary connection data."
  value       = equinix_ecx_l2_connection.this
}

output "secondary_connection" {
  description = "Secondary connection data."
  value       =  try(equinix_ecx_l2_connection.this.secondary_connection[0], null)
}
