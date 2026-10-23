#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

locals {
  # Snowflake audit logging is enabled by default, so there is nothing to turn on.
  # This module only creates the least-privilege role/user Guardium uses to read the audit data (optional)
  # and registers the "Snowflake Over JDBC Connect 2.0" Kafka-based profile in Guardium.

  account_label = split(".", var.snowflake_host)[0]
  udc_name      = var.udc_name != "" ? var.udc_name : lower(format("snowflake-%s", local.account_label))

  default_description = var.udc_description != "" ? var.udc_description : "GDP Snowflake Kafka connector for ${var.snowflake_host}"

  # The port must stay 443 (Snowflake deprecated custom ports), so none is set here.
  # db and schema are user-provided. The audit queries themselves are fully qualified
  # (SNOWFLAKE.INFORMATION_SCHEMA.*) so the session default database and schema do not affect them.
  connection_url = format(
    "jdbc:snowflake://%s/?warehouse=%s&db=%s&schema=%s",
    var.snowflake_host,
    var.warehouse,
    var.database,
    var.schema,
  )

  # Near-real-time audit data from the INFORMATION_SCHEMA table functions.
  # View aliases (QUERY_HISTORY_VIEW / QUERY_LOGIN_VIEW) are used by the filter to skip its own polling queries.
  # QUERY_HISTORY has no client IP, client environment or client application id, so those
  # are NULL and the filter falls back to its defaults. Each call returns at most the last 10000 rows of the last day.
  query_1 = "SELECT * FROM (SELECT QH.DATABASE_NAME AS DATABASE_NAME, QH.SESSION_ID AS SESSION_ID, TO_TIMESTAMP_LTZ(QH.END_TIME) AS QUERY_TIMESTAMP, CAST(NULL AS VARCHAR) AS CLIENT_IP, CURRENT_IP_ADDRESS() AS SERVER_IP, QH.USER_NAME AS USER_NAME, CAST(NULL AS VARCHAR) AS CLIENT_ENVIRONMENT, QH.QUERY_ID, QH.QUERY_TEXT, QH.QUERY_TYPE, QH.QUERY_TAG, QH.ROLE_NAME, CAST(NULL AS VARCHAR) AS CLIENT_APPLICATION_ID, QH.WAREHOUSE_NAME, QH.ERROR_CODE AS QUERY_ERROR_CODE, QH.ERROR_MESSAGE AS QUERY_ERROR_MESSAGE, QH.EXECUTION_STATUS AS QUERY_EXECUTION_STATUS, DATE_PART(epoch_millisecond, QH.END_TIME) AS QUERY_TIMESTAMP_EPOCH FROM TABLE(SNOWFLAKE.INFORMATION_SCHEMA.QUERY_HISTORY(END_TIME_RANGE_START => DATEADD('day', -1, CURRENT_TIMESTAMP()), RESULT_LIMIT => 10000)) QH WHERE QH.END_TIME IS NOT NULL AND QH.EXECUTION_STATUS <> 'RUNNING') AS QUERY_HISTORY_VIEW"

  query_2 = "SELECT * FROM (SELECT LH.USER_NAME AS USER_NAME, LH.CLIENT_IP AS CLIENT_IP, CURRENT_IP_ADDRESS() AS SERVER_IP, (LH.REPORTED_CLIENT_TYPE || ' ' || LH.REPORTED_CLIENT_VERSION) AS CLIENT_APPLICATION_ID, LH.IS_SUCCESS AS LOGIN_SUCCESS, LH.ERROR_CODE AS LOGIN_ERROR_CODE, LH.ERROR_MESSAGE AS LOGIN_ERROR_MESSAGE, TO_TIMESTAMP_LTZ(LH.EVENT_TIMESTAMP) AS LOGIN_TIMESTAMP, DATE_PART(epoch_millisecond, LH.EVENT_TIMESTAMP) AS LOGIN_TIMESTAMP_EPOCH FROM TABLE(SNOWFLAKE.INFORMATION_SCHEMA.LOGIN_HISTORY(TIME_RANGE_START => DATEADD('day', -1, CURRENT_TIMESTAMP()), TIME_RANGE_END => CURRENT_TIMESTAMP(), RESULT_LIMIT => 10000)) LH WHERE LH.IS_SUCCESS LIKE '%NO%') AS QUERY_LOGIN_VIEW"

  snowflake_kafka_csv = templatefile("${path.module}/templates/snowflakeJdbcKafka.tpl", {
    udc_name                 = local.udc_name
    description              = local.default_description
    credential_name          = var.udc_credential
    cluster_name             = var.kafka_cluster_name
    mu_count                 = var.mu_count
    use_elb                  = var.use_elb
    tracking_column_type     = "timestamp"
    jdbc_driver_library      = var.jdbc_driver_library
    connection_url           = local.connection_url
    tracking_column_query_1  = "QUERY_TIMESTAMP"
    query_1                  = local.query_1
    tracking_column_query_2  = "LOGIN_TIMESTAMP"
    query_2                  = local.query_2
    timestamp_initial_ms     = var.timestamp_initial_ms
    delay_interval           = var.delay_interval
    nodata_threshold_min     = var.nodata_threshold_min
    poll_interval            = var.poll_interval
    max_poll_records         = var.max_poll_records
    fetch_size               = var.fetch_size
    partition_lookback_hours = var.partition_lookback_hours
    poll_timeout_ms          = var.poll_timeout_ms
    url_type                 = "SNOWFLAKE"
    test_query               = "SELECT 1"
    timeout_ms_query         = var.timeout_ms_query
  })
}

//////
// Snowflake role, user and grants for the Guardium JDBC user
//////

resource "snowflake_account_role" "guardium" {
  count   = var.enable_audit_setup ? 1 : 0
  name    = var.role_name
  comment = "Role used by Guardium Universal Connector to read Snowflake audit data"
}

resource "snowflake_user" "guardium" {
  count             = var.enable_audit_setup ? 1 : 0
  name              = var.user_name
  password          = var.user_password
  default_role      = snowflake_account_role.guardium[0].name
  default_warehouse = var.warehouse
  comment           = "User used by Guardium Universal Connector"

  lifecycle {
    precondition {
      condition     = var.user_password != ""
      error_message = "user_password must be set when enable_audit_setup is true."
    }
  }
}

resource "snowflake_grant_account_role" "guardium_user" {
  count     = var.enable_audit_setup ? 1 : 0
  role_name = snowflake_account_role.guardium[0].name
  user_name = snowflake_user.guardium[0].name
}

# grant imported privileges on database snowflake to role <role-name>
# (gives access to SNOWFLAKE.INFORMATION_SCHEMA QUERY_HISTORY and LOGIN_HISTORY)
resource "snowflake_grant_privileges_to_account_role" "snowflake_db" {
  count             = var.enable_audit_setup ? 1 : 0
  account_role_name = snowflake_account_role.guardium[0].name
  privileges        = ["IMPORTED PRIVILEGES"]

  on_account_object {
    object_type = "DATABASE"
    object_name = "SNOWFLAKE"
  }
}

# Lets the role see other users' queries through the INFORMATION_SCHEMA table functions.
resource "snowflake_grant_privileges_to_account_role" "monitor_execution" {
  count             = var.enable_audit_setup ? 1 : 0
  account_role_name = snowflake_account_role.guardium[0].name
  privileges        = ["MONITOR EXECUTION"]
  on_account        = true
}

# GRANT USAGE ON WAREHOUSE <warehouse> TO ROLE <role-name>
resource "snowflake_grant_privileges_to_account_role" "warehouse" {
  count             = var.enable_audit_setup ? 1 : 0
  account_role_name = snowflake_account_role.guardium[0].name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse
  }
}

//////
// Universal Connector - can be disabled with enable_universal_connector = false
//////

module "snowflake-kafka-registration" {
  count            = var.enable_universal_connector ? 1 : 0
  source           = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  version          = "= 1.3.3"
  udc_name         = local.udc_name
  udc_csv_parsed   = local.snowflake_kafka_csv
  client_id        = var.gdp_client_id
  client_secret    = var.gdp_client_secret
  gdp_server       = var.gdp_server
  gdp_port         = var.gdp_port
  gdp_username     = var.gdp_username
  gdp_password     = var.gdp_password
  gdp_mu_host      = var.gdp_mu_host
  test_connections = true

  depends_on = [
    snowflake_grant_account_role.guardium_user,
    snowflake_grant_privileges_to_account_role.snowflake_db,
    snowflake_grant_privileges_to_account_role.warehouse,
    snowflake_grant_privileges_to_account_role.monitor_execution,
  ]
}
