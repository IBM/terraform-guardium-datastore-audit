#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

/**
 * # Snowflake with Universal Connector (Kafka, JDBC Connect 2.0)
 *
 * This example configures Guardium Data Protection to collect Snowflake audit logs
 * through the "Snowflake Over JDBC Connect 2.0" Kafka-based Universal Connector profile.
 *
 * Snowflake audit logging is enabled by default. When `enable_audit_setup` is true,
 * a dedicated role and user with read access to the audit data are created in Snowflake.
 */

# Used only when enable_audit_setup = true. Needs a role able to create roles/users
# and grant imported privileges on the SNOWFLAKE database (ACCOUNTADMIN).
provider "snowflake" {
  organization_name = var.snowflake_organization_name
  account_name      = var.snowflake_account_name
  user              = var.snowflake_admin_user
  password          = var.snowflake_admin_password
  role              = "ACCOUNTADMIN"
}

provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}

module "snowflake_audit_kafka" {
  source = "../../modules/snowflake-audit"

  # Snowflake
  snowflake_host = var.snowflake_host
  warehouse      = var.warehouse
  database       = var.database
  schema         = var.schema

  # Audit setup (role / user / grants)
  enable_audit_setup = var.enable_audit_setup
  role_name          = var.role_name
  user_name          = var.user_name
  user_password      = var.user_password

  # Guardium Data Protection
  gdp_server        = var.gdp_server
  gdp_port          = var.gdp_port
  gdp_username      = var.gdp_username
  gdp_password      = var.gdp_password
  gdp_client_id     = var.gdp_client_id
  gdp_client_secret = var.gdp_client_secret
  gdp_mu_host       = var.gdp_mu_host

  # Universal Connector
  enable_universal_connector = var.enable_universal_connector
  udc_name                   = var.udc_name
  udc_description            = var.udc_description
  udc_credential             = var.udc_credential

  # Kafka / JDBC Connect 2.0 profile
  kafka_cluster_name       = var.kafka_cluster_name
  mu_count                 = var.mu_count
  use_elb                  = var.use_elb
  jdbc_driver_library      = var.jdbc_driver_library
  timestamp_initial_ms     = var.timestamp_initial_ms
  delay_interval           = var.delay_interval
  nodata_threshold_min     = var.nodata_threshold_min
  poll_interval            = var.poll_interval
  max_poll_records         = var.max_poll_records
  fetch_size               = var.fetch_size
  partition_lookback_hours = var.partition_lookback_hours
  poll_timeout_ms          = var.poll_timeout_ms
  timeout_ms_query         = var.timeout_ms_query
}
