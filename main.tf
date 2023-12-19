data "equinix_fabric_service_profiles" "sp" {
  count = var.seller_profile_name != "" ? 1 : 0

  filter {
    property = "/name"
    operator = "="
    values = [var.seller_profile_name]
  }
}

data "equinix_fabric_ports" "primary" {
  count = var.port_name != "" ? 1 : 0

  filters {
    name = var.port_name
  }
}

data "equinix_fabric_ports" "secondary" {
  count = var.secondary_port_name != "" ? 1 : 0

  filters {
    name = var.secondary_port_name
  }
}

data "equinix_fabric_ports" "zside" {
  count = var.zside_port_name != "" ? 1 : 0

  filters {
    name = var.zside_port_name
  }
}

resource "random_string" "this" {
  length  = 3
  special = false
}

resource "equinix_fabric_connection" "primary"{
  name = var.redundancy_type == "REDUNDANT" && var.secondary_name == "" && var.name == "" ? format("%s-PRI", local.primary_name) : local.primary_name
  type = local.connection_type

  dynamic "notifications" {
    for_each = local.notification_users_by_type
    content {
      type = notifications.key
      emails = notifications.value
    }
  }

  additional_info = length(var.additional_info) > 0 ? [for item in var.additional_info : {
    key   = item.name
    value = item.value
  }] : null

  bandwidth = local.bandwidth

  redundancy {
    priority= "PRIMARY"
  }

  order {
    purchase_order_number= var.purchase_order_number != "" ? var.purchase_order_number : null
  }

  a_side {
    dynamic "service_token" {
      for_each = var.service_token_id != "" ? [var.service_token_id] : []
      content {
        type = "VC_TOKEN"
        uuid = service_token.value
      }
    }

    dynamic "access_point" {
      for_each = var.service_token_id == "" ? [1] : []
      content {
        type = local.aside_ap_type

        peering_type = var.named_tag != "" ? var.named_tag : null

        dynamic "port" {
          for_each = var.port_name != "" ? [data.equinix_fabric_ports.primary[0].data[0].uuid] : []
          content {
            uuid = port.value
          }
        }

        dynamic "link_protocol" {
          for_each = var.port_name != "" ? [1] : []
          content {
            type       = local.link_protocol_type == "UNTAGGEDEPL" ? "UNTAGGED" : local.link_protocol_type
            vlan_tag   = local.link_protocol_type == "DOT1Q" ? var.vlan_stag : null // vlanTag value specified for DOT1Q connections
            vlan_s_tag = local.link_protocol_type == "QINQ" ? var.vlan_stag : null // vlanSTag value specified for QINQ connections

            # This is adding ctag for any connection that is QINQ Aside AND not COLO on Zside OR when COLO on Zside is not QINQ Encapsulation Type
            vlan_c_tag = local.link_protocol_type == "QINQ" && (local.zside_ap_type != "COLO" || (local.zside_ap_type == "COLO" ? local.zside_link_protocol_type != "QINQ" : false)) ? var.vlan_ctag : null
          }
        }

        //  TODO (ocobles) support FCR
        # dynamic "router" {
        #   for_each = var.cloud_router_id != "" ? [var.cloud_router_id] : []
        #   content {
        #     uuid = router.value
        #   }
        # }

        dynamic "virtual_device" {
          for_each = var.network_edge_id != "" ? [var.network_edge_id] : []
          content {
            type = "EDGE"
            uuid = virtual_device.value
            // TODO (ocobles) allow use name instead of uuid
            // name = var.network_edge_name
          }
        }

        // Virtual device interface
        dynamic "interface" {
          for_each = var.network_edge_interface_id != 0 ? [var.network_edge_interface_id] : []
          content {
            type = "NETWORK"
            id   = interface.value
          }
        }
      }
    }
  }

  z_side {
    dynamic "service_token" {
      for_each = var.zside_service_token_id != "" ? [var.zside_service_token_id] : []
      content {
        type = "VC_TOKEN"
        uuid = service_token.value
      }
    }

    dynamic "access_point" {
      for_each = var.zside_service_token_id == "" ? [1] : []
      content {
        type = local.zside_ap_type
        authentication_key = var.seller_authorization_key != "" ? var.seller_authorization_key : null
        seller_region = local.primary_region

        dynamic "profile" {
          for_each = var.seller_profile_name != "" ? [1] : []
          content {
            type = data.equinix_fabric_service_profiles.sp[0].data[0].type
            uuid = data.equinix_fabric_service_profiles.sp[0].data[0].uuid
          }
        }

        dynamic "location" {
          for_each = local.primary_seller_metro_code != null ? [local.primary_seller_metro_code] : []
          content {
            metro_code = location.value
          }
        }

        //  TODO (ocobles) support Fabric Network
        # dynamic "network" {
        #   for_each = var.network_id != "" ? [var.network_id] : []
        #   content {
        #     uuid = network.value
        #   }
        # }

        dynamic "port" {
          for_each = var.zside_port_name != "" ? [data.equinix_fabric_ports.zside[0].data[0].uuid] : []
          content {
            uuid = port.value
          }
        }

        dynamic "link_protocol" {
          for_each = var.zside_port_name != "" ? [1] : []
          content {
            type       = local.zside_link_protocol_type == "UNTAGGEDEPL" ? "UNTAGGED" : local.zside_link_protocol_type
            vlan_tag   = local.zside_link_protocol_type == "DOT1Q" ? var.zside_vlan_stag : null
            vlan_s_tag = local.zside_link_protocol_type == "QINQ" ? var.zside_vlan_stag : null
            vlan_c_tag = local.zside_link_protocol_type == "QINQ" && local.link_protocol_type != "QINQ" ? var.zside_vlan_ctag : null
          }
        }
      }
    }
  }
}

# SECONDARY CONNECTION
resource "equinix_fabric_connection" "secondary"{
  count = var.redundancy_type == "REDUNDANT" ? 1 : 0

  name = local.secondary_name
  type = local.connection_type

  dynamic "notifications" {
    for_each = local.notification_users_by_type
    content {
      type = notifications.key
      emails = notifications.value
    }
  }

  additional_info = length(var.additional_info) > 0 ? [for item in var.additional_info : {
    key   = item.name
    value = item.value
  }] : null

  bandwidth = local.secondary_bandwidth

  redundancy {
    priority = "SECONDARY"
    group    = one(equinix_fabric_connection.primary.redundancy).group
  }

  order {
    purchase_order_number= var.purchase_order_number != "" ? var.purchase_order_number : null
  }

  a_side {
    dynamic "service_token" {
      for_each = var.secondary_service_token_id != "" ? [var.secondary_service_token_id] : []
      content {
        type = "VC_TOKEN"
        uuid = service_token.value
      }
    }

    dynamic "access_point" {
      for_each = var.service_token_id == "" ? [1] : []
      content {
        type = local.aside_ap_type

        peering_type = var.named_tag != "" ? var.named_tag : null

        dynamic "port" {
          for_each = var.port_name != "" ? [coalesce(local.secondary_port_uuid, data.equinix_fabric_ports.primary[0].data[0].uuid)] : []
          content {
            uuid = port.value
          }
        }

        dynamic "link_protocol" {
          for_each = var.port_name != "" ? [1] : []
          content {
            type       = local.secondary_link_protocol_type == "UNTAGGEDEPL" ? "UNTAGGED" : local.secondary_link_protocol_type
            vlan_tag   = local.secondary_link_protocol_type == "DOT1Q" ? var.secondary_vlan_stag : null // vlanTag value specified for DOT1Q connections
            vlan_s_tag = local.secondary_link_protocol_type == "QINQ" ? var.secondary_vlan_stag : null // vlanSTag value specified for QINQ connections

            # This is adding ctag for any connection that is QINQ Aside AND not COLO on Zside OR when COLO on Zside is not QINQ Encapsulation Type
            vlan_c_tag = local.secondary_link_protocol_type == "QINQ" && (local.zside_ap_type != "COLO" || (local.zside_ap_type == "COLO" ? local.zside_link_protocol_type != "QINQ" : false)) ? var.secondary_vlan_ctag : null
          }
        }

        //  TODO (ocobles) support FCR
        # dynamic "router" {
        #   for_each = var.cloud_router_id != "" ? [coalesce(var.cloud_router_secondary_id, var.cloud_router_id)] : []
        #   content {
        #     uuid = router.value
        #   }
        # }

        dynamic "virtual_device" {
          for_each = var.network_edge_id != "" ? [coalesce(var.network_edge_secondary_id, var.network_edge_id)] : []
          content {
            type = "EDGE"
            uuid = virtual_device.value
            // TODO (ocobles) allow use name instead of uuid
            // name = var.network_edge_name
          }
        }

        // Virtual device interface
        dynamic "interface" {
          for_each = var.network_edge_secondary_interface_id != 0 ? [var.network_edge_secondary_interface_id] : []
          content {
            type = "NETWORK"
            id   = interface.value
          }
        }
      }
    }
  }

  z_side {
    dynamic "service_token" {
      for_each = var.secondary_zside_service_token_id != "" ? [var.secondary_zside_service_token_id] : []
      content {
        type = "VC_TOKEN"
        uuid = service_token.value
      }
    }

    dynamic "access_point" {
      for_each = var.secondary_zside_service_token_id == "" ? [1] : []
      content {
        type = local.zside_ap_type
        authentication_key = var.secondary_seller_authorization_key != "" ? var.secondary_seller_authorization_key : null
        seller_region = var.secondary_seller_region != "" ? var.secondary_seller_region : local.primary_region

        dynamic "profile" {
          for_each = var.seller_profile_name != "" ? [1] : []
          content {
            type = data.equinix_fabric_service_profiles.sp[0].data[0].type
            uuid = data.equinix_fabric_service_profiles.sp[0].data[0].uuid
          }
        }

        dynamic "location" {
          for_each = local.secondary_seller_metro_code != null ? [local.secondary_seller_metro_code] : []
          content {
            metro_code = location.value
          }
        }

        //  TODO (ocobles) support Fabric Network
        # dynamic "network" {
        #   for_each = var.network_id != "" ? [var.network_id] : []
        #   content {
        #     uuid = network.value
        #   }
        # }

        dynamic "port" {
          for_each = var.zside_port_name != "" ? [data.equinix_fabric_ports.zside[0].data[0].uuid] : []
          content {
            uuid = port.value
          }
        }

        dynamic "link_protocol" {
          for_each = var.zside_port_name != "" ? [1] : []
          content {
            type       = local.zside_link_protocol_type == "UNTAGGEDEPL" ? "UNTAGGED" : local.zside_link_protocol_type
            vlan_tag   = local.zside_link_protocol_type == "DOT1Q" ? var.zside_vlan_stag : null
            vlan_s_tag = local.zside_link_protocol_type == "QINQ" ? var.zside_vlan_stag : null
            vlan_c_tag = local.zside_link_protocol_type == "QINQ" && local.link_protocol_type != "QINQ" ? var.zside_vlan_ctag : null
          }
        }
      }
    }
  }
}
