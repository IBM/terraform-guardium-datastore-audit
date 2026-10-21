# Snowflake Audit (Kafka, JDBC Connect 2.0)

Registers a Guardium Universal Connector profile of type **Snowflake Over JDBC Connect 2.0** and, optionally,
creates the Snowflake role/user that Guardium uses to read the audit views.

Snowflake audit logging (query and login history) is **enabled by default**,
so there is nothing to switch on. The module therefore only:

1. (`enable_audit_setup = true`) creates a role and user, and grants `IMPORTED PRIVILEGES` on the `SNOWFLAKE` database,
   `USAGE` on the warehouse and `MONITOR EXECUTION`. These correspond to the SQL in the plug-in README.
2. (`enable_universal_connector = true`) builds the profile CSV and registers it in Guardium with
   `IBM/gdp/guardium//modules/connect-datasource-to-uc`, testing the connection.

## Prerequisites

- The Snowflake JDBC driver jar (3.13.30 or 3.16.0) uploaded to Guardium; set `jdbc_driver_library` to its file name.
- A credential (Snowflake user + password) created in Guardium Credential Management; set `udc_credential`.
  It must match `user_name`/`user_password` when `enable_audit_setup` is true.
- Guardium Data Protection 12.2.2 or later, with a Kafka cluster attached to Central Manager.
- When `enable_audit_setup` is true, the Snowflake provider must authenticate as a role able to create roles/users and
  grant imported privileges on `SNOWFLAKE` (`ACCOUNTADMIN`). The provider block belongs to the calling configuration.

## Notes

- The JDBC port must remain 443.
- Events are read from the `SNOWFLAKE.INFORMATION_SCHEMA.QUERY_HISTORY()` / `LOGIN_HISTORY()` table functions. Near
  real time, `delay_interval` defaults to 0, and the role gets `MONITOR EXECUTION` so it can see other users' queries.
  Limitations: query events carry no client IP, client environment (OS/OS user) or client application id (the filter
  uses its defaults), and each poll sees at most the last 10000 rows of the last day.
- For key-pair authentication or a proxy, adjust the connection URL as described in the plug-in README.

## Usage

```hcl
module "snowflake_audit" {
  source = "../../modules/snowflake-audit"

  snowflake_host = "abc12345.us-east-1.aws.snowflakecomputing.com"
  warehouse      = "COMPUTE_WH"

  enable_audit_setup = true
  user_password      = var.snowflake_user_password

  udc_credential    = "snowflake-credential"
  gdp_server        = var.gdp_server
  gdp_username      = var.gdp_username
  gdp_password      = var.gdp_password
  gdp_client_id     = var.gdp_client_id
  gdp_client_secret = var.gdp_client_secret
  gdp_mu_host       = var.gdp_mu_host
}
```

See [`examples/snowflake-audit-kafka`](../../examples/snowflake-audit-kafka) for a complete example.

## Key inputs

| Name | Description | Default |
|------|-------------|---------|
| `snowflake_host` | Account hostname for the JDBC URL | n/a (required) |
| `udc_credential` | Guardium credential name | n/a (required) |
| `database`, `schema` | Database and schema in the JDBC URL. They must already exist; the module does not create them or grant the Guardium role access to them (only `SNOWFLAKE`, the warehouse and `MONITOR EXECUTION` are granted) | `SNOWFLAKE`, `PUBLIC` |
| `enable_audit_setup` | Create role, user and grants | `true` |
| `enable_universal_connector` | Register the profile in Guardium | `true` |
| `jdbc_driver_library` | Driver jar name in Guardium | `snowflake-jdbc-3.13.30.jar` |
| `delay_interval` | Polling delay in ms | `0` |
| `kafka_cluster_name`, `mu_count`, `use_elb` | Kafka / ELB placement | `kafka`, `2`, `false` |

All other profile columns (`poll_interval`, `max_poll_records`, `fetch_size`, `partition_lookback_hours`,
`poll_timeout_ms`, `timeout_ms_query`, `nodata_threshold_min`, `timestamp_initial_ms`) are exposed as variables with
the defaults from the Guardium CSV template.
