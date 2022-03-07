provider "equinix" {
  client_id     = "someID"
  client_secret = "someSecret"
}

module "equinix_fabric_connection" {
  source = "github.com/equinix-labs/terraform-equinix-connection"

  # required variables
  fabric_notification_users = ["example@equinix.com"]

  # optional variables
  seller_profile_name      = "AWS Direct Connect"
  seller_metro_code        = "SV"
  seller_authorization_key = "AWS-Account-ID"
  network_edge_id          = "NE-virtual-router-uuid"
}