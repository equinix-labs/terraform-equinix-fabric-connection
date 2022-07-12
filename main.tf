data "equinix_ecx_l2_sellerprofile" "seller" {
  count   = var.seller_profile_name != "" ? 1 : 0
  name    = var.seller_profile_name
}

data "equinix_ecx_port" "primary" {
  count   = var.port_name != "" ? 1 : 0
  name    = var.port_name
}

data "equinix_ecx_port" "secondary" {
  count   = var.secondary_port_name != "" ? 1 : 0
  name    = var.secondary_port_name
}

data "equinix_ecx_port" "zside" {
  count   = var.zside_port_name != "" ? 1 : 0
  name    = var.zside_port_name
}

locals  {
  primary_speed = ((var.speed == null || var.speed == 0) && var.seller_profile_name != "") ? [
    for s in sort(formatlist("%03d", [
      for band in data.equinix_ecx_l2_sellerprofile.seller[0].speed_band : band.speed
    ])) : tonumber(s)
  ][0] : var.speed

  primary_speed_unit = (var.speed_unit == "" && var.seller_profile_name != "") ? [
    for band in data.equinix_ecx_l2_sellerprofile.seller[0].speed_band : band.speed_unit
    if band.speed == local.primary_speed
  ][0] : var.speed_unit

  primary_seller_metro_code = (var.seller_metro_name != "" && var.seller_profile_name != "") ? [
    for metro in data.equinix_ecx_l2_sellerprofile.seller[0].metro : metro.code
    if metro.name == title(var.seller_metro_name)
   ][0] : var.seller_metro_code

  primary_region = (var.seller_region == "" && var.seller_profile_name != "") ? [
    for metro in data.equinix_ecx_l2_sellerprofile.seller[0].metro : try(keys(metro.regions)[0], null)
    if metro.code == local.primary_seller_metro_code
  ][0] : var.seller_region

  primary_name  = var.name != "" ? var.name : upper(format("%s-%s-%s", split(" ", coalesce(var.seller_profile_name, var.zside_port_name))[0], local.primary_seller_metro_code, random_string.this.result))

  secondary_seller_metro_code = (var.secondary_seller_metro_name != "" && var.seller_profile_name != "") ? [
    for metro in data.equinix_ecx_l2_sellerprofile.seller[0].metro : metro.code
    if metro.name == title(var.secondary_seller_metro_name)
  ][0] : var.secondary_seller_metro_code

  secondary_name = var.secondary_name != "" ? var.secondary_name : format("%s-SEC", local.primary_name)
  secondary_port_uuid = var.secondary_port_name != "" ? data.equinix_ecx_port.secondary[0].id : null
}

resource "random_string" "this" {
  length  = 3
  special = false
}

resource "equinix_ecx_l2_connection" "this" {
  name                  = var.redundancy_type == "REDUNDANT" && var.secondary_name == "" && var.name == "" ? format("%s-PRI", local.primary_name) : local.primary_name
  profile_uuid          = var.seller_profile_name != "" ? data.equinix_ecx_l2_sellerprofile.seller[0].uuid : null
  speed                 = local.primary_speed
  speed_unit            = local.primary_speed_unit
  notifications         = var.notification_users
  purchase_order_number = var.purchase_order_number != "" ? var.purchase_order_number : null
  seller_metro_code     = local.primary_seller_metro_code
  seller_region         = local.primary_region
  authorization_key     = var.seller_authorization_key != "" ? var.seller_authorization_key : null
  service_token         = var.service_token_id != "" ? var.service_token_id : null
  port_uuid             = var.port_name != "" ? data.equinix_ecx_port.primary[0].id : null
  vlan_stag             = var.vlan_stag != 0 ? var.vlan_stag : null
  vlan_ctag             = var.vlan_ctag != 0 ? var.vlan_ctag : null
  device_uuid           = var.network_edge_id != "" ? var.network_edge_id : null
  device_interface_id   = var.network_edge_interface_id != 0 ? var.network_edge_interface_id : null
  named_tag             = var.named_tag != "" ? var.named_tag : null
  zside_port_uuid       = var.zside_port_name != "" ? data.equinix_ecx_port.zside[0].id : null
  zside_vlan_stag       = var.zside_vlan_stag != 0 ? var.zside_vlan_stag : null
  zside_vlan_ctag       = var.zside_vlan_ctag != 0 ? var.zside_vlan_ctag : null
  zside_service_token   = var.zside_service_token_id != "" ? var.zside_service_token_id : null
  
  dynamic "additional_info" {
    for_each = var.additional_info

    content {
      name = additional_info.value.name
      value = additional_info.value.value
    }
  }

  dynamic "secondary_connection" {
    for_each = var.redundancy_type == "REDUNDANT" ? [1] : []
    content {
        name                = local.secondary_name
        speed               = var.secondary_speed != 0 ? var.secondary_speed : null
        speed_unit          = var.secondary_speed_unit != "" ? var.secondary_speed_unit : null
        port_uuid           = var.port_name != "" ? coalesce(local.secondary_port_uuid, data.equinix_ecx_port.primary[0].id) : null
        vlan_stag           = var.secondary_vlan_stag != 0 ? var.secondary_vlan_stag : null
        vlan_ctag           = var.secondary_vlan_ctag != 0 ? var.secondary_vlan_ctag : null
        device_uuid         = var.network_edge_id != "" ? coalesce(var.network_edge_secondary_id, var.network_edge_id) : null
        device_interface_id = var.network_edge_secondary_interface_id != 0 ? var.network_edge_secondary_interface_id : null
        service_token       = var.service_token_id != "" && var.secondary_service_token_id != "" ? var.secondary_service_token_id : null
        seller_metro_code   = local.secondary_seller_metro_code != "" ? local.secondary_seller_metro_code : null
        seller_region       = var.secondary_seller_region != "" ? var.secondary_seller_region : null
        authorization_key   = var.secondary_seller_authorization_key != "" ? var.secondary_seller_authorization_key : null
    }
  }
}
