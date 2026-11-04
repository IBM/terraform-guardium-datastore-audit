# Snowflake Audit with IBM Guardium Data Protection (Kafka, JDBC Connect 2.0)

This example demonstrates how to configure Snowflake audit collection with IBM Guardium Data Protection using the [`snowflake-audit`](../../modules/snowflake-audit) module and the Kafka-based `Snowflake Over JDBC Connect 2.0` Universal Connector profile.

## Architecture

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│                     │     │                     │     │                     │
│  Snowflake          │────►│  Guardium Universal │────►│  Guardium Data      │
│  QUERY_HISTORY /    │JDBC │  Connector (Kafka,  │     │  Protection         │
│  LOGIN_HISTORY      │poll │  JDBC Connect 2.0)  │     │                     │
│                     │     │                     │     │                     │
└─────────────────────┘     └─────────────────────┘     └─────────────────────┘
```

## Data Flow

1. Snowflake records query and login activity (audit logging is enabled by default)
2. The Guardium Universal Connector polls `SNOWFLAKE.INFORMATION_SCHEMA` over JDBC in near real time
3. Events are published to the Kafka cluster attached to Guardium Central Manager
4. Guardium processes and analyzes the Snowflake activity

## Overview

This Terraform configuration:

1. (`enable_audit_setup = true`) Creates a Snowflake role and user for Guardium with the required grants
2. (`enable_universal_connector = true`) Registers a `Snowflake Over JDBC Connect 2.0` Universal Connector profile in Guardium and tests the connection

## Prerequisites

Before using this example, ensure you have:

1. **Snowflake**:
   - An existing Snowflake account, warehouse, database and schema (see [Database and Schema](#database-and-schema))
   - When `enable_audit_setup = true`, an admin user that can authenticate as `ACCOUNTADMIN`
   - When `enable_audit_setup = false`, an existing Snowflake role and user for Guardium with the required grants (`IMPORTED PRIVILEGES` on `SNOWFLAKE`, `USAGE` on the warehouse and `MONITOR EXECUTION`). No admin credentials are needed

2. **Guardium Data Protection** (12.2.2 or later):
   - A running Guardium Data Protection instance with a Kafka cluster attached to Central Manager
   - The Snowflake JDBC driver jar (3.13.30 or 3.16.0) uploaded to Guardium; set `jdbc_driver_library` to its file name
   - A credential (Snowflake user + password) created in Guardium Credential Management; set `udc_credential`. It must match the Snowflake user (`user_name`/`user_password` when `enable_audit_setup = true`, otherwise your existing user)
   - Completed the one-time manual configurations as described in [Preparing Guardium Documentation](https://github.com/IBM/terraform-guardium-gdp/blob/main/docs/preparing-guardium.md):
     - OAuth client registered via `grdapi register_oauth_client`

## Database and Schema

`database` and `schema` are only used to build the JDBC connection URL. They must already exist in Snowflake; this example does not create them.

## Usage

### 1. Create a terraform.tfvars File

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values. Set `enable_audit_setup = false` if the Snowflake role/user already exist.

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Apply the Configuration

```bash
terraform plan
terraform apply
```

### 4. Verify the Configuration

After successful application:

1. Log in to your Guardium Data Protection web interface
2. Navigate to **Universal Connector** → **Datasource Profile Management**
3. Verify the `Snowflake Over JDBC Connect 2.0` profile has been created and is active
4. Confirm the profile is deployed to the expected managed units

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| snowflake_host | Snowflake account hostname for the JDBC URL (no scheme, no port; port remains 443) | `string` | n/a | yes |
| snowflake_organization_name | Snowflake organization name, the part before the dash in `<org>-<account>` | `string` | `""` | no (yes if `enable_audit_setup = true`) |
| snowflake_account_name | Snowflake account name, the part after the dash in `<org>-<account>` | `string` | `""` | no (yes if `enable_audit_setup = true`) |
| snowflake_admin_user | Snowflake admin user able to create roles/users and grant permissions | `string` | `""` | no (yes if `enable_audit_setup = true`) |
| snowflake_admin_password | Password of the Snowflake admin user | `string` | `""` | no (yes if `enable_audit_setup = true`) |
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
| enable_universal_connector | Whether to enable the universal connector module | `bool` | `true` | no |
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

## Additional Resources

- [IBM Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Guardium Universal Connector Guide](https://www.ibm.com/docs/en/guardium/12.2?topic=connectors-universal-connector)
- [Snowflake Access Control and Privileges](https://docs.snowflake.com/en/user-guide/security-access-control-privileges)
- [Snowflake Account Usage Views](https://docs.snowflake.com/en/sql-reference/account-usage)

## License

Copyright IBM Corp. 2026
SPDX-License-Identifier: Apache-2.0
