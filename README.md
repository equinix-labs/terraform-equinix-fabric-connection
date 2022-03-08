## Equinix Fabric L2 Connection Terraform module

[![Experimental](https://img.shields.io/badge/Stability-Experimental-red.svg)](https://github.com/equinix-labs/standards#about-uniform-standards)
[![terraform](https://github.com/equinix-labs/terraform-equinix-template/actions/workflows/integration.yaml/badge.svg)](https://github.com/equinix-labs/terraform-equinix-template/actions/workflows/integration.yaml)

`terraform-equinix-fabric-connection` is a minimal Terraform module that utilizes [Terraform provider for Equinix](https://registry.terraform.io/providers/equinix/equinix/latest) to set up an Equinix Fabric L2 connection.

As part of Platform Equinix, your infrastructure can connect with other parties, such as public cloud providers, network service providers, or your own colocation cages in Equinix by defining an [Equinix Fabric - software-defined interconnection](https://docs.equinix.com/en-us/Content/Interconnection/Fabric/Fabric-landing-main.htm).

```html
  Origin                                             Destination
  (A-side)                                           (Z-side)

┌────────────────┐                                 ┌────────────────────┐
│ Equinix Fabric │         Equinix Fabric          │                    │
│ Port / Network ├─────    l2 connection   ───────►│ Service Provider / │
│ Edge Device /  │      (50 Mbps - 10 Gbps)        │ Customer / My self │
│ Service Token  │                                 │                    │
└────────────────┘                                 └────────────────────┘
```

-> **NOTE:**
Setting Up an Equinix Fabric connection requires combine and configure several parameters depending on the origin and destination types. It also requires configuration in the platform of the service you are connecting to, such as creating an Interconnect Attachment in Google Cloud platform, or approving a Direct Connect request in AWS. Although this module can be used directly, it is intended to be consumed by other service-specific modules to abstract you from this process and to include also all the necessary configuration on the target platform.

### Usage

This project is experimental and supported by the user community. Equinix does not provide support for this project.

Install Terraform using the official guides at <https://learn.hashicorp.com/tutorials/terraform/install-cli>.

This project may be forked, cloned, or downloaded and modified as needed as the base in your integrations and deployments.

This project may also be used as a [Terraform module](https://learn.hashicorp.com/collections/terraform/modules).

To use this module in a new project, create a file such as:

```hcl
# main.tf
provider "equinix" {}

module "equinix_fabric_connection" {
  source  = "equinix-labs/fabric-connection/equinix"

  # required variables
  notification_users = ["example@equinix.com"]

  # optional variables
  seller_profile_name      = "Azure ExpressRoute"
  seller_metro_code        = "FR"
  seller_authorization_key = "Express-Route-Service-Key"
  port_name                = "Fabric-Port-FR-Pri"
  vlan_stag                = 1010
  named_tag                = "PRIVATE"
  redundancy_type          = "Redundant"
  secondary_port_name      = "Fabric-Port-FR-Sec"
  secondary_vlan_stag      = 1020
}
```

Run `terraform init -upgrade` and `terraform apply`.

#### Resources

| Name | Type |
| :-----: | :------: |
| [random_string.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [equinix_ecx_l2_connection.this](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/equinix_ecx_l2_connection) | resource |
| [equinix_ecx_l2_sellerprofile.this](https://registry.terraform.io/providers/equinix/equinix/latest/docs/data-sources/equinix_ecx_l2_sellerprofile) | data source |
| [equinix_ecx_port.primary](https://registry.terraform.io/providers/equinix/equinix/latest/docs/data-sources/equinix_ecx_port) | data source |
| [equinix_ecx_port.secondary](https://registry.terraform.io/providers/equinix/equinix/latest/docs/data-sources/equinix_ecx_port) | data source |
| [equinix_ecx_port.zside](https://registry.terraform.io/providers/equinix/equinix/latest/docs/data-sources/equinix_ecx_port) | data source |

#### Variables

See <https://registry.terraform.io/modules/equinix-labs/fabric-connection/equinix/latest?tab=inputs> for a description of all variables.

#### Outputs

See <https://registry.terraform.io/modules/equinix-labs/fabric-connection/equinix/latest?tab=outputs> for a description of all outputs.

### Examples

- [examples/simple](examples/simple/)
