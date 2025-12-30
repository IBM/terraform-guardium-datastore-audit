#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

//////
// AWS variables
//////

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
}

//////
// MariaDB RDS variables
//////

variable "mariadb_rds_cluster_identifier" {
  type        = string
  description = "MariaDB RDS cluster identifier to be monitored"
  default     = "guardium-mariadb"
}

variable "force_failover" {
  type        = bool
  description = "To failover the database instance, requires multi AZ databases. Results in minimal downtime"
  default     = false
}

variable "audit_events" {
  type        = string
  description = "Comma-separated list of events to audit (CONNECT,QUERY,TABLE,QUERY_DDL,QUERY_DML,QUERY_DCL)"
  default     = "CONNECT,QUERY"
}

variable "audit_file_rotations" {
  type        = string
  description = "Number of audit file rotations to keep"
  default     = "10"
}

variable "audit_file_rotate_size" {
  type        = string
  description = "Size in bytes before rotating audit file"
  default     = "1000000"
}

variable "audit_incl_users" {
  type        = string
  description = "Comma-separated list of users to include in audit logs (SERVER_AUDIT_INCL_USERS). If set, only these users will be audited. Leave empty to audit all users."
  default     = ""
}

variable "audit_excl_users" {
  type        = string
  description = "Comma-separated list of users to exclude from audit logs (SERVER_AUDIT_EXCL_USERS). Example: 'rdsadmin,testuser'. The rdsadmin user queries the database every second for health checks, which can cause log files to grow quickly."
  default     = "rdsadmin"
}

variable "audit_query_log_limit" {
  type        = string
  description = "Maximum query length to log in bytes (SERVER_AUDIT_QUERY_LOG_LIMIT). Queries longer than this will be truncated. Default is 1024 bytes."
  default     = "1024"
}

variable "cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to CloudWatch. Valid values for MariaDB: audit"
  default     = ["audit"]
}

//////
// Guardium variables
//////

variable "udc_name" {
  type        = string
  description = "Name for universal connector. Is used for all aws objects"
  default     = "mariadb-gdp"
}

variable "udc_aws_credential" {
  type        = string
  description = "Name of AWS credential defined in Guardium"
}

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
// Universal Connector variables
//////

variable "enable_universal_connector" {
  type        = bool
  description = "Whether to enable the universal connector module. Set to false to completely disable the universal connector for a run."
  default     = true
}

variable "csv_start_position" {
  type        = string
  description = "Start position for UDC"
  default     = "end"
}

variable "csv_interval" {
  type        = string
  description = "Polling interval for UDC"
  default     = "5"
}

variable "csv_event_filter" {
  type        = string
  description = "UDC Event filters"
  default     = ""
}

variable "log_export_type" {
  description = "The type of log exporting to be configured. Option: Cloudwatch"
  type        = string
  default     = "Cloudwatch"

  validation {
    condition     = var.log_export_type == "Cloudwatch"
    error_message = "log_export_type must be 'Cloudwatch'"
  }
}

variable "codec_pattern" {
  type        = string
  description = "Codec pattern for RDS MariaDB CloudWatch logs"
  default     = ""
}

variable "cloudwatch_endpoint" {
  type        = string
  description = "Custom endpoint URL for AWS CloudWatch. Leave empty to use default AWS endpoint"
  default     = ""
}

variable "use_aws_bundled_ca" {
  type        = bool
  description = "Whether to use the AWS bundled CA certificates for CloudWatch connection"
  default     = true
}

