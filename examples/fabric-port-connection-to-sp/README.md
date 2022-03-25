## Fabric Port connection to Service Provider Example

This example demonstrates usage of the Equinix Connection module to establish a non-redundant Equinix Fabric L2 Connection from a
Network Edge Device to AWS Direct Connect.

## Usage

To provision this example, you should clone the github repository and run terraform from within this directory:

```bash
git clone https://github.com/equinix-labs/terraform-equinix-fabric-connection.git
cd terraform-equinix-fabric-connection/examples/fabric-port-connection-to-sp
terraform init
terraform apply
```

Note that this example may create resources which cost money. Run 'terraform destroy' when you don't need these resources.
