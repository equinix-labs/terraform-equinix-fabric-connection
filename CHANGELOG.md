## 0.3.1 (July 20, 2022)

BUG FIXES:

- `equinix_ecx_l2_connection.seller_metro_code` and `equinix_ecx_l2_connection.seller_region` must be null if `seller_profile_name` is not specified

## 0.3.0 (July 19, 2022)

FEATURES:

- Added input variable `zside_service_token_id` to support single connections using z-side Equinix Service Tokens

BUG FIXES:

- typo `purchase_order` was `purcharse_order` [#1](https://github.com/equinix-labs/terraform-equinix-fabric-connection/issues/1)

## 0.2.0 (April 27, 2022)

FEATURES:

- Supported definition of `additional_info` blocks.

## 0.1.1 (April 18, 2022)

BUG FIXES:

- `-PRI` suffix was added to the name of primary connection even if there was no secondary connection.

## 0.1.0 (March 25, 2022)

Initial release.

FEATURES:

- Supported single and redundant connections from Equinix Fabric Port , Network Edge Device, Equinix Service Token.
