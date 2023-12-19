locals {
  sp_supported_bandwidths = ((var.speed == null || var.speed == 0) && var.seller_profile_name != "") ? [
    for config in data.equinix_fabric_service_profiles.sp[0].data[0].access_point_type_configs : config.supported_bandwidths
  ][0] : []

  bandwidth = length(local.sp_supported_bandwidths) > 0 ? [
    for s in sort(formatlist("%03d", local.sp_supported_bandwidths)) : tonumber(s) if s > 0
  ][0] : var.speed

  secondary_bandwidth = var.redundancy_type == "REDUNDANT" && (var.secondary_speed == null || var.secondary_speed == 0) ? local.bandwidth : var.secondary_speed

  primary_seller_metro_code = var.seller_profile_name != "" ? var.seller_metro_code == "" ? [
    for metro in data.equinix_fabric_service_profiles.sp[0].data[0].metros : metro.code
    if metro.name == title(var.seller_metro_name)
  ][0] : var.seller_metro_code : null

  primary_region = var.seller_profile_name != "" ? var.seller_region == "" ? [
    for metro in data.equinix_fabric_service_profiles.sp[0].data[0].metros : try(keys(metro.seller_regions)[0], null)
    if metro.code == local.primary_seller_metro_code
  ][0] : var.seller_region : null

  primary_name = var.name != "" ? var.name : upper(format("%s-%s-%s", split(" ", coalesce(
    var.seller_profile_name, var.zside_port_name
  ))[0], local.primary_seller_metro_code, random_string.this.result))

  secondary_seller_metro_code = (var.secondary_seller_metro_name != "" && var.seller_profile_name != "") ? [
    for metro in data.equinix_fabric_service_profiles.sp[0].data[0].metros : metro.code
    if metro.name == title(var.secondary_seller_metro_name)
  ][0] : var.secondary_seller_metro_code != "" ? var.secondary_seller_metro_code : local.primary_seller_metro_code

  secondary_name      = var.secondary_name != "" ? var.secondary_name : format("%s-SEC", local.primary_name)
  secondary_port_uuid = var.secondary_port_name != "" ? data.equinix_fabric_ports.secondary[0].data[0].uuid : null

  notification_users_by_type = length(var.notification_users) > 0 ? merge(
    var.notification_users_by_type,
    {
      "ALL" = contains(keys(var.notification_users_by_type), "ALL") ? distinct(
        concat(var.notification_users_by_type["ALL"], var.notification_users)
      ) : var.notification_users
    }
  ) : var.notification_users_by_type

  // TODO (ocobles) consider VG, IGW, SUBNET, GW use cases
  // TODO (ocobles) replace aside_ap_type line below to support FCR
  # aside_ap_type = var.network_edge_id != "" ? "VD" : var.cloud_router_id != "" ? "CLOUD_ROUTER" : "COLO"
  aside_ap_type = var.network_edge_id != "" ? "VD" : "COLO"
  // TODO (ocobles) replace zside_ap_type line below to support Fabric Network
  # zside_ap_type = (var.zside_port_name != "" || var.zside_service_token_id != "")  ? "COLO" : var.network_id != "" ? "NETWORK" : "SP"
  zside_ap_type = (var.zside_port_name != "" || var.zside_service_token_id != "")  ? "COLO" : "SP"

  link_protocol_type = var.port_name != "" ? one(data.equinix_fabric_ports.primary[0].data.0.encapsulation).type : ""
  secondary_link_protocol_type = var.redundancy_type == "REDUNDANT" && var.port_name != "" ? one(data.equinix_fabric_ports.secondary[0].data.0.encapsulation).type : ""
  zside_link_protocol_type = var.zside_port_name != "" ? one(data.equinix_fabric_ports.zside[0].data.0.encapsulation).type : ""

  connection_type = var.connection_type != "" ? var.connection_type : (
      local.link_protocol_type == "UNTAGGEDEPL" && local.zside_link_protocol_type == "UNTAGGEDEPL"
    ) ? "EPL_VC" : (
      (local.link_protocol_type == "QINQ" && local.zside_link_protocol_type == "UNTAGGEDEPL") ||
      (local.link_protocol_type == "UNTAGGEDEPL" && local.zside_link_protocol_type == "QINQ")
    ) ? "ACCESS_EPL_VC" : "EVPL_VC" # Default value EVPL_VC should cover use cases: COLO2COLO, COLO2SP, VD2COLO, VD2COLO(TOKEN), COLO(TOKEN)2SP
  #   // TODO (ocobles) replace last ACCESS_EPL_VC condition with below code to support FCR and Fabric Network
  #   # ) ? "ACCESS_EPL_VC" : (
  #   # local.aside_ap_type == "CLOUD_ROUTER" && (local.zside_ap_type == "COLO" || local.zside_ap_type == "SP")
  #   # ) ? "IP_VC" : (
  #   # local.aside_ap_type == "CLOUD_ROUTER" && local.zside_ap_type == "NETWORK"
  #   # ) ? "IPWAN_VC" : (
  #   # local.aside_ap_type == "VD" && local.zside_ap_type == "NETWORK"
  #   # ) ? "EVPLAN_VC" : (
  #   # local.aside_ap_type == "COLO" && local.zside_ap_type == "NETWORK" && local.link_protocol_type != "UNTAGGED"
  #   # ) ? "EVPLAN_VC" : (
  #   # local.aside_ap_type == "COLO" && local.zside_ap_type == "NETWORK" && local.link_protocol_type == "UNTAGGED"
  #   # ) ? "EPLAN_VC" : "EVPL_VC" # Default value EVPL_VC should cover use cases: COLO2COLO, COLO2SP, VD2COLO, VD2COLO(TOKEN), COLO(TOKEN)2SP
}
