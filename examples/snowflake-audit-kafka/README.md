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

1. Snowflake records query and login activity (audit logging is enabled by default; there is nothing to switch on)
2. The Guardium Universal Connector polls those views over JDBC, using the Snowflake user configured in Guardium Credential Management
3. Events are published to the Kafka cluster attached to Guardium Central Manager
4. Guardium processes and analyzes the Snowflake activity

## Overview

This Terraform configuration:

1. (`enable_audit_setup = true`) Creates a Snowflake role and user for Guardium, and grants `IMPORTED PRIVILEGES` on the `SNOWFLAKE` database, `USAGE` on the warehouse and `MONITOR EXECUTION`
2. (`enable_universal_connector = true`) Registers a `Snowflake Over JDBC Connect 2.0` Universal Connector profile in Guardium and tests the connection

## Prerequisites

Before using this example, ensure you have:

1. **Snowflake**:
   - An existing Snowflake account and warehouse
   - An existing database and schema to put in the JDBC URL (see [Database and Schema](#database-and-schema))
   - When `enable_audit_setup = true`, an admin user that can authenticate as `ACCOUNTADMIN` (needed to create roles/users and grant imported privileges on `SNOWFLAKE`)

2. **Guardium Data Protection** (12.2.2 or later):
   - A running Guardium Data Protection instance with a Kafka cluster attached to Central Manager
   - The Snowflake JDBC driver jar (3.13.30 or 3.16.0) uploaded to Guardium; set `jdbc_driver_library` to its file name
   - A credential (Snowflake user + password) created in Guardium Credential Management; set `udc_credential`. It must match `user_name`/`user_password` when `enable_audit_setup = true`
   - Completed the one-time manual configurations as described in [Preparing Guardium Documentation](https://github.com/IBM/terraform-guardium-gdp/blob/main/docs/preparing-guardium.md):
     - OAuth client registered via `grdapi register_oauth_client`

## Database and Schema

`database` and `schema` are used only to build the JDBC connection URL, for example:

```
jdbc:snowflake://<id>.<region>.<provider>.snowflakecomputing.com/?warehouse=COMPUTE_WH&db=TEST_DB&schema=PUBLIC
```

Please note:

- **The database and schema must already exist in Snowflake.** This example does not create them and does not check that they exist.
- **The Guardium role is not granted access to them.** The grants created by `enable_audit_setup` cover only the `SNOWFLAKE` database, the warehouse and (for `information_schema`) `MONITOR EXECUTION`. If you set `database`/`schema` to something other than the defaults (`SNOWFLAKE` / `PUBLIC`), grant the Guardium role access yourself, for example:

  ```sql
  GRANT USAGE ON DATABASE TEST_DB TO ROLE GUARDIUM_UC_ROLE;
  GRANT USAGE ON SCHEMA TEST_DB.PUBLIC TO ROLE GUARDIUM_UC_ROLE;
  ```

- The audit queries are fully qualified (`SNOWFLAKE.ACCOUNT_USAGE.*` / `SNOWFLAKE.INFORMATION_SCHEMA.*`), so `database` and `schema` do not change which data is collected. They set the session's default database and schema, which is relevant to the connection test Guardium runs when the profile is registered.
- If you are unsure, keep the defaults (`database = "SNOWFLAKE"`, `schema = "PUBLIC"`).

## Usage

### 1. Create a terraform.tfvars File

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values.

Set `enable_audit_setup = false` if the Snowflake role/user already exist; the Snowflake provider credentials are then unused.

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

## Audit Source

Events are read from the `SNOWFLAKE.INFORMATION_SCHEMA.QUERY_HISTORY()` and `LOGIN_HISTORY()` table functions, in near real time (`delay_interval` defaults to 0).

Limitations: query events carry no client IP, client environment or client application id (the filter uses its defaults), and each poll sees at most the last 10000 rows of the last day.

## Inputs

See [`variables.tf`](./variables.tf) for the full list. Key variables:

| Name | Description | Default | Required |
|------|-------------|---------|:--------:|
| snowflake_host | Account hostname for the JDBC URL (no scheme, no port; the port must remain 443) | n/a | yes |
| warehouse | Warehouse used by the Guardium JDBC user | `COMPUTE_WH` | no |
| database | Database in the JDBC URL. Must already exist; see [Database and Schema](#database-and-schema) | `SNOWFLAKE` | no |
| schema | Schema in the JDBC URL. Must already exist; see [Database and Schema](#database-and-schema) | `PUBLIC` | no |
| enable_audit_setup | Create the Snowflake role, user and grants | `true` | no |
| snowflake_organization_name | Organization part (before the dash) of `<org>-<account>`; used when `enable_audit_setup` is true | `""` | no |
| snowflake_account_name | Account part (after the dash) of `<org>-<account>`; used when `enable_audit_setup` is true | `""` | no |
| snowflake_admin_user | Admin user for the Snowflake provider; used when `enable_audit_setup` is true | `""` | no |
| snowflake_admin_password | Admin password for the Snowflake provider; used when `enable_audit_setup` is true | `""` | no |
| role_name | Name of the Snowflake role created for Guardium | `GUARDIUM_UC_ROLE` | no |
| user_name | Name of the Snowflake JDBC user for Guardium | `GUARDIUM_UC_USER` | no |
| user_password | Password of the Snowflake JDBC user; required when `enable_audit_setup` is true | `""` | no |
| gdp_server | Guardium Central Manager hostname | n/a | yes |
| gdp_port | Guardium Central Manager port | `8443` | no |
| gdp_username | Guardium username | n/a | yes |
| gdp_password | Guardium password | n/a | yes |
| gdp_client_id | Guardium OAuth client ID | n/a | yes |
| gdp_client_secret | Guardium OAuth client secret | n/a | yes |
| gdp_mu_host | Guardium Managed Unit hostnames (comma separated) | `""` | no |
| enable_universal_connector | Register the profile in Guardium | `true` | no |
| udc_name | Name of the Universal Connector profile | `snowflake-<account label>` | no |
| udc_description | Description of the Universal Connector profile | `GDP Snowflake Kafka connector for <snowflake_host>` | no |
| udc_credential | Credential name in Guardium Credential Management | n/a | yes |
| kafka_cluster_name | Kafka cluster name configured in Guardium | `kafka` | no |
| mu_count | Number of Managed Units used by ELB | `2` | no |
| use_elb | Whether to use ELB for the Kafka-based UC | `false` | no |
| jdbc_driver_library | Snowflake JDBC driver jar name in Guardium | `snowflake-jdbc-3.13.30.jar` | no |
| delay_interval | Polling delay in ms | `0` | no |

All other profile settings (`timestamp_initial_ms`, `nodata_threshold_min`, `poll_interval`, `max_poll_records`, `fetch_size`, `partition_lookback_hours`, `poll_timeout_ms`, `timeout_ms_query`) are exposed as variables with defaults from the Guardium CSV template.

## Outputs

| Name | Description |
|------|-------------|
| udc_name | Name of the Universal Connector profile |
| connection_url | JDBC connection URL used by the profile (contains no credentials) |
| role_name | Snowflake role used by Guardium |
| user_name | Snowflake user used by Guardium |
