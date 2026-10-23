#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

//////
// Snowflake variables
//////

variable "snowflake_host" {
  type        = string
  description = "Snowflake account hostname used in the JDBC URL, e.g. <id>.<region>.<provider>.snowflakecomputing.com (no scheme, no port; the port must remain 443)"
}

variable "warehouse" {
  type        = string
  description = "Snowflake warehouse used by the Guardium JDBC user to run the audit queries"
  default     = "COMPUTE_WH"
}

variable "database" {
  type        = string
  description = "Snowflake database used in the JDBC connection URL. The audit views live in the SNOWFLAKE database"
  default     = "SNOWFLAKE"
}

variable "schema" {
  type        = string
  description = "Snowflake schema used in the JDBC connection URL"
  default     = "PUBLIC"
}

//////
// Audit setup (role, user and grants for the Guardium JDBC user)
//////

variable "enable_audit_setup" {
  type        = bool
  description = "Whether to create the Snowflake role, user and grants required to read SNOWFLAKE.ACCOUNT_USAGE. Set to false to skip and only manage the Universal Connector (Snowflake audit logging itself is enabled by default)."
  default     = true
}

variable "role_name" {
  type        = string
  description = "Name of the Snowflake role created for Guardium"
  default     = "GUARDIUM_UC_ROLE"
}

variable "user_name" {
  type        = string
  description = "Name of the Snowflake user created for Guardium (the JDBC user)"
  default     = "GUARDIUM_UC_USER"
}

variable "user_password" {
  type        = string
  description = "Password of the Snowflake user created for Guardium. Required when enable_audit_setup is true. Use the same value in the Guardium credential referenced by udc_credential."
  sensitive   = true
  default     = ""

  validation {
    condition     = var.user_password == "" || length(var.user_password) >= 8
    error_message = "user_password must be at least 8 characters."
  }
}

//////
// Guardium Configuration
//////

variable "gdp_client_secret" {
  type        = string
  description = "Client secret from output of grdapi register_oauth_client"
  sensitive   = true
}

variable "gdp_client_id" {
  type        = string
  description = "Client id used when running grdapi register_oauth_client"
}

variable "gdp_server" {
  type        = string
  description = "Hostname/IP address of Guardium Central Manager"
}

variable "gdp_port" {
  type        = string
  description = "Port of Guardium Central Manager"
  default     = "8443"
}

variable "gdp_username" {
  type        = string
  description = "Username of Guardium Web UI user"
}

variable "gdp_password" {
  type        = string
  description = "Password of Guardium Web UI user"
  sensitive   = true
}

variable "gdp_mu_host" {
  type        = string
  description = "Comma separated list of Guardium Managed Units to deploy profile"
  default     = ""
}

//////
// Universal Connector Control
//////

variable "enable_universal_connector" {
  type        = bool
  description = "Whether to enable the universal connector module. Set to false to completely disable the universal connector for a run."
  default     = true
}

variable "udc_name" {
  type        = string
  description = "Name of the Universal Connector profile. Defaults to snowflake-<first label of snowflake_host>."
  default     = ""
}

variable "udc_description" {
  type        = string
  description = "Description for the Universal Connector profile. Defaults to an auto-generated description."
  default     = ""
}

variable "udc_credential" {
  type        = string
  description = "Name of the credential (Snowflake JDBC user/password) configured in Guardium Credential Management"
}

//////
// Kafka / JDBC Connect 2.0 profile settings
//////

variable "kafka_cluster_name" {
  type        = string
  description = "Kafka cluster name configured in Guardium"
  default     = "kafka"
}

variable "mu_count" {
  type        = number
  description = "Number of Managed Units used by ELB"
  default     = 2
}

variable "use_elb" {
  type        = bool
  description = "Whether to use ELB for the Kafka-based UC"
  default     = false
}

variable "jdbc_driver_library" {
  type        = string
  description = "File name of the Snowflake JDBC driver jar uploaded to Guardium (tested with snowflake-jdbc-3.13.30.jar and snowflake-jdbc-3.16.0.jar)"
  default     = "snowflake-jdbc-3.13.30.jar"
}

variable "timestamp_initial_ms" {
  type        = number
  description = "Initial polling time (epoch ms) for audit logs. 0 = start from the beginning of available history"
  default     = 0
}

variable "delay_interval" {
  type        = number
  description = "Delay interval in ms. INFORMATION_SCHEMA is near real time, so the default is 0."
  default     = 0
}

variable "nodata_threshold_min" {
  type        = number
  description = "No data threshold in minutes"
  default     = 60
}

variable "poll_interval" {
  type        = number
  description = "Poll interval in ms"
  default     = 10000
}

variable "max_poll_records" {
  type        = number
  description = "Maximum number of records returned per poll"
  default     = 1000
}

variable "fetch_size" {
  type        = number
  description = "JDBC fetch size"
  default     = 500
}

variable "partition_lookback_hours" {
  type        = number
  description = "Partition lookback in hours"
  default     = 6
}

variable "poll_timeout_ms" {
  type        = number
  description = "Poll timeout in ms"
  default     = 500
}

variable "timeout_ms_query" {
  type        = number
  description = "Timeout in ms for the connection test query"
  default     = 600000
}
