# Fabric Port connection to Service Provider Example

This example demonstrates usage of the Equinix Connection module to establish
a non-redundant Equinix Fabric L2 Connection from a
Network Edge Device to AWS Direct Connect.

## Usage

To provision this example, you should clone the github repository and run
terraform from within this directory:

```bash
git clone https://github.com/equinix-labs/terraform-equinix-fabric-connection.git
cd terraform-equinix-fabric-connection/examples/fabric-port-connection-to-sp
terraform init
terraform apply
```

Note that this example may create resources which cost money. Run
'terraform destroy' when you don't need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_equinix"></a> [equinix](#requirement\_equinix) | ~> 1.14 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_equinix_fabric_connection"></a> [equinix\_fabric\_connection](#module\_equinix\_fabric\_connection) | ../.. | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fabric_connection_id"></a> [fabric\_connection\_id](#output\_fabric\_connection\_id) | Primary connection id. |
| <a name="output_fabric_connection_provider_status"></a> [fabric\_connection\_provider\_status](#output\_fabric\_connection\_provider\_status) | Primary connection provider status. |
| <a name="output_fabric_connection_status"></a> [fabric\_connection\_status](#output\_fabric\_connection\_status) | Primary connection equinix status. |
<!-- END_TF_DOCS -->
