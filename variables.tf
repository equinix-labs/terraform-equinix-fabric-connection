variable "seller_profile_name" {
  type        = string
  description = <<EOF
  Unique identifier of the service provider's profile. One of 'seller_profile_name' or
  'zside_port_name' is required.
  EOF
  default     = ""
}

variable "name" {
  type        = string
  description = <<EOF
  Name of the connection resource that will be created. It will be auto-generated if not
  specified.
  EOF
  default     = ""
}

variable "port_name" {
  type        = string
  description = <<EOF
  Name of the buyer's port from which the connection would originate. One of 'port_name',
  'network_edge_id' or 'service_token_id' is required.
  EOF
  default     = ""
}

variable "speed" {
  type        = number
  description = <<EOF
  Speed/Bandwidth to be allocated to the connection - (MB or GB). If not specified, it will be used
  the minimum bandwidth available for the specified seller profile.
  EOF
  default     = 0
}

variable "speed_unit" {
  type        = string
  description = "Unit of the speed/bandwidth to be allocated to the connection."
  default     = ""

  validation {
    condition = (
      var.speed_unit == "" ? true : contains(["GB", "MB"], var.speed_unit)
    )
    error_message = "Valid values are (MB, GB)."
  } 
}

variable "seller_authorization_key" {
  type = string
  description = <<EOF
  Text field used to authorize connection on the provider side. Value depends on a provider service
  profile used for connection.
  EOF
  default = ""
}

variable "seller_metro_code" {
  type        = string
  description = <<EOF
  Metro code where the connection will be created. If you do not know the code,'seller_metro_name'
  can be use instead.
  EOF
  default     = ""

  validation {
    condition = ( 
      var.seller_metro_code == "" ? true : can(regex("^[A-Z]{2}$", var.seller_metro_code))
    )
    error_message = "Valid metro code consits of two capital leters, i.e. 'FR', 'SV', 'DC'."
  }
}

variable "seller_metro_name" {
  type        = string
  description = <<EOF
  Metro name where the connection will be created, i.e. 'Frankfurt', 'Silicon Valley', 'Ashburn'.
  Only required if 'seller_profile_name' is specified and in the absence of 'seller_metro_code'.
  EOF
  default     = ""
}

variable "seller_region" {
  type        = string
  description = <<EOF
  The region in which the seller port resides, i.e. 'eu-west-1'. Required only in cases where you
  need a specific region of a service provider with several regions per metro. Generally there is
  only one region per metro, and it will be used the first available region in the metro of the
  specified seller profile.
  EOF
  default     = ""
}

variable "notification_users" {
  type        = list(string)
  description = "A list of email addresses used for sending connection update notifications."

  validation {
    condition     = length(var.notification_users) > 0
    error_message = "Notification list cannot be empty."
  }
}

variable "purchase_order_number" {
  type        = string
  description = "Connection's purchase order number to reflect on the invoice."
  default     = ""
}

variable "vlan_stag" {
  type        = number
  description = <<EOF
  S-Tag/Outer-Tag of the primary connection - a numeric character ranging from 2 - 4094. Required
  if 'port_name' is specified.
  EOF
  default     = 0
}

variable "vlan_ctag" {
  type        = number
  description = <<EOF
  C-Tag/Inner-Tag of the primary connection - a numeric character ranging from
  2 - 4094.
  EOF
  default     = 0
}

variable "zside_port_name" {
  type        = string
  description = <<EOF
  Name of the buyer's port from which the connection would originate the port on the remote side
  (z-side). Required when destination is another port instead of a service profile. Usually, if
  you don't have an existing private service profile, this option offers a simple, streamlined
  way to set up a connection between your own ports. Not compatible with redundant connections.
  EOF
  default     = ""
}

variable "zside_vlan_stag" {
  type        = number
  description = <<EOF
  S-Tag/Outer-Tag of the connection on the Z side. Required if 'zside_port_name' is specified. A
  numeric character ranging from 2 - 4094.
  EOF
  default     = 0
}

variable "zside_vlan_ctag" {
  type        = number
  description = <<EOF
  C-Tag/Inner-Tag of the connection on the Z side. This is only applicable with 'named_tag'. A
  numeric character ranging from 2 - 4094.
  EOF
  default     = 0
}

variable "named_tag" {
  type        = string
  description = <<EOF
  The type of peering to set up in case when connecting to Azure Express Route. One of 'PRIVATE',
  'MICROSOFT'.
  EOF
  default     = ""
}

variable "additional_info" {
  type        = list(object({
      name    = string,
      value   = string
    })
  )
  description = <<EOF
  Additional parameters required for some service profiles. It should be a list of maps containing
  'name' and 'value  e.g. `[{ name='asn' value = '65000'}, { name='ip' value = '192.168.0.1'}]`.
  EOF
  default     = []
}

variable "service_token_id" {
  type        = string
  description = <<EOF
  Unique Equinix Fabric key shared with you by a provider that grants you authorization to use
  their interconnection asset from (a-side) which the connection would originate.
  EOF
  default     = ""
}

variable "zside_service_token_id" {
  type        = string
  description = <<EOF
  Unique Equinix Fabric key shared with you by a provider that grants you authorization to use
  their interconnection asset to (z-side) which the connection would arrive.
  EOF
  default     = ""
}

variable "network_edge_id" {
  type        = string
  description = <<EOF
  Unique identifier of the Network Edge virtual device from which the connection would
  originate.
  EOF
  default     = ""
}

variable "network_edge_interface_id" {
  type        = number
  description = <<EOF
  Applicable with 'network_edge_id', identifier of network interface on a given device, used for a
  connection. If not specified then first available interface will be selected.
  EOF
  default     = 0
}

variable "redundancy_type" {
  type        = string
  description = <<EOF
  Whether to create a single connection or redundant. Fabric secondary variables will take no
  effect unless value 'REDUNDANT' is specified.
  EOF
  default     = "SINGLE"

  validation {
    condition = (contains(["SINGLE", "REDUNDANT"], var.redundancy_type))
    error_message = "Valid values for 'redundancy_type' are (SINGLE, REDUNDANT)."
  } 
}

variable "secondary_name" {
  type        = string
  description = <<EOF
  Name of the secondary connection that will be created. It will be auto-generated
  if not specified.
  EOF
  default     = ""
}

variable "secondary_port_name" {
  type        = string
  description = <<EOF
  Name of the buyer's port from which the secondary connection would originate. If not specified,
  and 'port_name' is specified, and 'redundancy_type' is 'REDUNDANT', then the value of 'port_name'
  will be used.
  EOF
  default     = ""
}

variable "secondary_speed" {
  type        = number
  description = <<EOF
  Speed/Bandwidth to be allocated to the secondary connection - (MB or GB). If not specified then
  primary connection speed will be used.
  EOF
  default     = 0
}

variable "secondary_speed_unit" {
  type        = string
  description = <<EOF
  Unit of the speed/bandwidth to be allocated to the secondary connection. If not specified then
  primary connection speed unit will be used.
  EOF
  default     = ""

  validation {
    condition = (
      var.secondary_speed_unit == "" ? true : contains(["GB", "MB"], var.secondary_speed_unit)
    )
    error_message = "Valid values are (MB, GB)."
  } 
}

variable "secondary_vlan_stag" {
  type        = number
  description = <<EOF
  S-Tag/Outer-Tag of the secondary connection. A numeric character ranging from 2 - 4094. Required
  if 'secondary_port_name' is specified. 
  EOF
  default     = 0
}

variable "secondary_vlan_ctag" {
  type        = number
  description = <<EOF
  C-Tag/Inner-Tag of the secondary connection - a numeric character ranging from
  2 - 4094.
  EOF
  default     = 0
}

variable "secondary_seller_authorization_key" {
  type = string
  description = <<EOF
  Text field used to authorize secondary connection on the provider side. Value depends on a
  provider service profile used for connection.
  EOF
  default = ""
}

variable "secondary_seller_metro_code" {
  type        = string
  description = <<EOF
  Metro code where the secondary connection will be created. If not specified then primary
  connection metro code will be used.
  EOF
  default     = ""

  validation {
    condition = ( 
      var.secondary_seller_metro_code == "" ? true : can(regex("^[A-Z]{2}$", var.secondary_seller_metro_code))
    )
    error_message = "Valid metro code consits of two capital leters, i.e. 'FR', 'SV', 'DC'."
  }
}

variable "secondary_seller_metro_name" {
  type        = string
  description = <<EOF
  Metro name where the secondary connection will be created, i.e. 'Frankfurt', 'Silicon Valley',
  'Ashburn'. If not specified then primary connection metro name will be used.
  EOF
  default     = ""
}

variable "secondary_seller_region" {
  type        = string
  description = <<EOF
  The region in which the seller port resides, i.e. 'eu-west-1'. If not specified then primary
  connection region will be used.
  EOF
  default     = ""
}

variable "network_edge_secondary_id" {
  type        = string
  description = <<EOF
  Unique identifier of the Network Edge virtual device from which the secondary connection would
  originate. If not specified, and 'network_edge_id' is specified, and 'redundancy_type' is
  'REDUNDANT' then primary edge device will be used.
  EOF
  default     = ""
}

variable "network_edge_secondary_interface_id" {
  type        = number
  description = <<EOF
  Applicable with 'network_edge_id' or 'network_edge_secondary_id', identifier of network interface
  on a given device, used for a connection. If not specified then first available interface will be
  selected.
  EOF
  default     = 0
}

variable "secondary_service_token_id" {
  type        = string
  description = <<EOF
  Unique Equinix Fabric key shared with you by a provider that grants you authorization to use
  their interconnection asset from (a-side) which the secondary connection would originate. Required if
  'service_token_id' is specified, and 'redundancy_type' is 'REDUNDANT'.
  EOF
  default     = ""
}
