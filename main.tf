data "equinix_ecx_l2_sellerprofile" "seller" {
  name = var.seller_profile_name
}

data "equinix_ecx_port" "primary" {
  count   = coalesce(var.port_name, false) ? 1 : 0
  name    = var.port_name
}

data "equinix_ecx_port" "secondary" {
  count   = coalesce(var.secondary_port_name, false) ? 1 : 0
  name    = var.secondary_port_name
}

data "equinix_ecx_port" "zside" {
  count   = coalesce(var.zside_port_name, false) ? 1 : 0
  name    = var.secondary_port_name
}

locals  {
  primary_speed = var.speed == null ? [
    for s in sort(formatlist("%03d", [
      for band in data.equinix_ecx_l2_sellerprofile.seller.speed_band : band.speed
    ])) : tonumber(s)
  ][0] : var.speed

  primary_speed_unit = var.speed_unit == null ? [
    for band in data.equinix_ecx_l2_sellerprofile.seller.speed_band : band.speed_unit
    if band.speed == local.primary_speed
  ][0] : var.speed_unit

  primary_seller_metro_code = var.seller_metro_name != null ? [
    for metro in data.equinix_ecx_l2_sellerprofile.seller.metro : metro.code
    if metro.name == title(var.seller_metro_name)
   ][0] : var.seller_metro_code

  primary_region = var.seller_region == null ? [
    for metro in data.equinix_ecx_l2_sellerprofile.seller.metro : keys(metro.regions)[0]
    if metro.code == local.primary_seller_metro_code
  ][0] : var.seller_region

  primary_name  = var.name != null ? var.name : upper(format("%s-%s-%s", split(" ", coalesce(var.seller_profile_name, var.zside_port_name))[0], local.primary_seller_metro_code, random_string.this.result))

  secondary_seller_metro_code = var.secondary_seller_metro_name != null ? [
    for metro in data.equinix_ecx_l2_sellerprofile.seller.metro : metro.code
    if metro.name == title(var.secondary_seller_metro_name)
  ][0] : var.secondary_seller_metro_code

  secondary_name = var.secondary_name != null ? var.secondary_name : format("%s-SEC", local.primary_name)
  secondary_port_uuid = var.secondary_port_name != null ? data.equinix_ecx_port.secondary[0].id : null
}

resource "random_string" "this" {
  length  = 3
  special = false
}

resource "equinix_ecx_l2_connection" "this" {
  name                  = var.secondary_name != null ? format("%s-PRI", local.primary_name) : local.primary_name
  profile_uuid          = data.equinix_ecx_l2_sellerprofile.seller.uuid
  speed                 = local.primary_speed
  speed_unit            = local.primary_speed_unit
  notifications         = var.notification_users
  purchase_order_number = var.purcharse_order_number
  seller_metro_code     = local.primary_seller_metro_code
  seller_region         = local.primary_region
  authorization_key     = var.seller_authorization_key
  service_token         = var.service_token_id
  port_uuid             = var.port_name != null ? data.equinix_ecx_port.primary[0].id : null
  vlan_stag             = var.vlan_stag
  vlan_ctag             = var.vlan_ctag
  device_uuid           = var.network_edge_id
  device_interface_id   = var.network_edge_interface_id
  named_tag             = var.named_tag
  zside_port_uuid       = var.zside_port_name != null ? data.equinix_ecx_port.zside[0].id : null
  zside_vlan_stag       = var.zside_vlan_stag
  zside_vlan_ctag       = var.zside_vlan_ctag
  
  dynamic "secondary_connection" {
    for_each = var.redundancy_type == "redundant" ? [1] : []
    content {
        name                = local.secondary_name
        speed               = var.secondary_speed
        speed_unit          = var.secondary_speed_unit
        port_uuid           = var.port_name != null ? coalesce(local.secondary_port_uuid, data.equinix_ecx_port.primary[0].id) : null
        vlan_stag           = var.secondary_vlan_stag
        vlan_ctag           = var.secondary_vlan_ctag
        device_uuid         = var.network_edge_id != null ? coalesce(var.network_edge_secondary_id, var.network_edge_id) : null
        device_interface_id = var.network_edge_secondary_interface_id
        service_token       = var.secondary_service_token_id
        seller_metro_code   = local.secondary_seller_metro_code
        seller_region       = var.secondary_seller_region 
        authorization_key   = var.secondary_seller_authorization_key
    }
  }
}
