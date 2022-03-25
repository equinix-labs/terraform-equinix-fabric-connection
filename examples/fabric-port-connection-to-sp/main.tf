provider "equinix" {
  client_id     = "someID"
  client_secret = "someSecret"
}

module "equinix-fabric-connection" {
  source = "equinix-labs/fabric-connection/equinix"

  # required variables
  notification_users = ["example@equinix.com"]

  # optional variables
  seller_profile_name      = "AWS Direct Connect"
  seller_metro_name        = "frankfurt"
  seller_authorization_key = "AWS-account-ID"
  network_edge_id          = "NE-device-Uuid"
}

output "fabric_connection_id" {
  value = module.equinix-fabric-connection.primary_connection.id
}

output "fabric_connection_status" {
  value = module.equinix-fabric-connection.primary_connection.status
}

output "fabric_connection_provider_status" {
  value = module.equinix-fabric-connection.primary_connection.provider_status
}
