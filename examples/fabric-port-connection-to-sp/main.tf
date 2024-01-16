provider "equinix" {
  client_id     = "someID"
  client_secret = "someSecret"
}

module "equinix_fabric_connection" {
  # TEMPLATE: Replace this path with the Git repo path or Terraform Registry path
  # source = "equinix-labs/fabric-connection/equinix"
  source = "../.."

  # required variables
  notification_users = ["example@equinix.com"]

  # optional variables
  seller_profile_name      = "AWS Direct Connect"
  seller_metro_name        = "frankfurt"
  seller_authorization_key = "AWS-account-ID"
  network_edge_id          = "NE-device-Uuid"
}
