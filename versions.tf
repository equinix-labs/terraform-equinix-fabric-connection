terraform {
  required_version = ">= 0.13"

  required_providers {
    equinix = {
      source  = "equinix/equinix"
      version = "~> 1.14"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
  provider_meta "equinix" {
    module_name = "equinix-fabric-connection"
  }
}
