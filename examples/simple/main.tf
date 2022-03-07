provider "equinix" {
  # client_id     = "someID"
  # client_secret = "someSecret"
}

module "equinix_fabric_connection" {
  source = "github.com/equinix-labs/terraform-equinix-connection"

  # required variables
  notification_users = ["example@equinix.com"]

  # optional variables
  seller_profile_name      = "AWS Direct Connect"
  seller_metro_name        = "frankfurt"
  seller_authorization_key = "AWS-account-ID"
  network_edge_id          = "NE-device-Uuid"
}

output "fabric_connection_id" {
  value = module.equinix_fabric_connection.primary_connection_uuid
}

output "fabric_connection_name" {
  value = module.equinix_fabric_connection.primary_connection_name
}
