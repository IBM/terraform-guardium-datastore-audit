# Snowflake Audit Configuration

This module configures audit logging for Snowflake with IBM Guardium Data Protection. It optionally creates the least-privilege Snowflake role and user for Guardium and registers the Kafka-based **Snowflake Over JDBC Connect 2.0** Universal Connector profile in Guardium.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.2 and above** with a Kafka cluster attached to Central Manager.

## Prerequisites

Before using this module, you need to:

1. **Snowflake Account**: Have an existing Snowflake account with a virtual warehouse, database, and schema.
2. **Snowflake Admin Credentials** (optional): When `enable_audit_setup = true`, the Snowflake provider must authenticate as `ACCOUNTADMIN` (or a role with sufficient privileges to create users, roles, and grant permissions).
3. **Guardium Data Protection**: GDP 12.2.2 or later with a Kafka cluster configured on Central Manager.
4. **Snowflake JDBC Driver**: Upload the Snowflake JDBC driver jar (`snowflake-jdbc-3.13.30.jar` or `snowflake-jdbc-3.16.0.jar`) to Guardium.
5. **Guardium Credentials**: Create a credential (Snowflake user + password) in Guardium Credential Management (`udc_credential`). When `enable_audit_setup = true`, this must match `user_name` and `user_password`.
6. **Guardium OAuth Client**: Register an OAuth client in Guardium via `grdapi register_oauth_client`.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| snowflake | ~> 2.0 |
| guardium-data-protection | = 1.5.2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| snowflake_host | Snowflake account hostname for the JDBC URL (no scheme, no port; port remains 443) | `string` | n/a | yes |
| warehouse | Snowflake warehouse used by the Guardium JDBC user to run audit queries | `string` | `"COMPUTE_WH"` | no |
| database | Snowflake database in the JDBC connection URL | `string` | `"SNOWFLAKE"` | no |
| schema | Snowflake schema in the JDBC connection URL | `string` | `"PUBLIC"` | no |
| enable_audit_setup | Whether to create the Snowflake role, user, and grants for Guardium | `bool` | `true` | no |
| role_name | Name of the Snowflake role created for Guardium | `string` | `"GUARDIUM_UC_ROLE"` | no |
| user_name | Name of the Snowflake user created for Guardium (JDBC user) | `string` | `"GUARDIUM_UC_USER"` | no |
| user_password | Password of the Snowflake user created for Guardium | `string` | `""` | no (yes if `enable_audit_setup = true`) |
| gdp_server | Hostname or IP address of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Username of Guardium Web UI user | `string` | n/a | yes |
| gdp_password | Password of Guardium Web UI user | `string` | n/a | yes |
| gdp_client_id | Client ID from `grdapi register_oauth_client` | `string` | n/a | yes |
| gdp_client_secret | Client secret from `grdapi register_oauth_client` | `string` | n/a | yes |
| gdp_mu_host | Comma-separated list of Guardium Managed Units to deploy profile | `string` | `""` | no |
| enable_universal_connector | Whether to enable the universal connector profile registration | `bool` | `true` | no |
| udc_name | Name of the Universal Connector profile (defaults to `snowflake-<account>`) | `string` | `""` | no |
| udc_description | Description for the Universal Connector profile | `string` | `""` | no |
| udc_credential | Name of the credential configured in Guardium Credential Management | `string` | n/a | yes |
| kafka_cluster_name | Kafka cluster name configured in Guardium | `string` | `"kafka"` | no |
| mu_count | Number of Managed Units used by ELB | `number` | `2` | no |
| use_elb | Whether to use ELB for the Kafka-based Universal Connector | `bool` | `false` | no |
| jdbc_driver_library | File name of the Snowflake JDBC driver jar uploaded to Guardium | `string` | `"snowflake-jdbc-3.13.30.jar"` | no |
| timestamp_initial_ms | Initial polling time (epoch ms) for audit logs (0 = start from beginning of available history) | `number` | `0` | no |
| delay_interval | Delay interval in ms | `number` | `0` | no |
| nodata_threshold_min | No data threshold in minutes | `number` | `60` | no |
| poll_interval | Poll interval in ms | `number` | `10000` | no |
| max_poll_records | Maximum number of records returned per poll | `number` | `1000` | no |
| fetch_size | JDBC fetch size | `number` | `500` | no |
| partition_lookback_hours | Partition lookback in hours | `number` | `6` | no |
| poll_timeout_ms | Poll timeout in ms | `number` | `500` | no |
| timeout_ms_query | Timeout in ms for the connection test query | `number` | `600000` | no |

## Outputs

| Name | Description |
|------|-------------|
| profile_csv | Universal Connector profile CSV |
| udc_name | Name of the Universal Connector |
| snowflake_host | Snowflake account hostname used in the JDBC URL |
| warehouse | Snowflake warehouse used by the Guardium user |
| database | Snowflake database in the JDBC URL |
| schema | Snowflake schema in the JDBC URL |
| connection_url | JDBC connection URL used by the profile (contains no credentials) |
| role_name | Snowflake role used by Guardium (null when `enable_audit_setup = false`) |
| user_name | Snowflake user used by Guardium |

## Troubleshooting

### Connection test fails when registering the profile
- Confirm `snowflake_host` contains no scheme (`https://`) or port (Snowflake uses port 443 by default).
- Confirm the JDBC driver jar specified in `jdbc_driver_library` has been uploaded to Guardium.
- Confirm the credential name in `udc_credential` exists in Guardium Credential Management and contains valid Snowflake credentials.
- If using non-default `database` or `schema`, confirm they exist and the Guardium role has `USAGE` permissions on them.

### Role or user already exists
- Set `enable_audit_setup = false` and ensure the existing role and user have `IMPORTED PRIVILEGES` on `SNOWFLAKE`, `USAGE` on the warehouse, and `MONITOR EXECUTION` on the account.

### No events in Guardium
- Confirm the Guardium role has `MONITOR EXECUTION` on the account, otherwise it cannot view other users' queries in `SNOWFLAKE.INFORMATION_SCHEMA`.
- Confirm the Universal Connector profile is deployed to the expected Managed Units and the Kafka cluster is attached and active in Guardium Central Manager.

## Examples

See the [`examples/snowflake-audit-kafka`](../../examples/snowflake-audit-kafka) directory for a complete working example.

## Additional Resources

- [IBM Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Guardium Universal Connector Guide](https://www.ibm.com/docs/en/guardium/12.2?topic=connectors-universal-connector)
- [Snowflake Access Control and Privileges](https://docs.snowflake.com/en/user-guide/security-access-control-privileges)
- [Snowflake Account Usage Views](https://docs.snowflake.com/en/sql-reference/account-usage)

## License

Copyright IBM Corp. 2026
SPDX-License-Identifier: Apache-2.0
