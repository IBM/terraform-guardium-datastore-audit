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
// Aurora MySQL variables
//////

variable "aurora_mysql_cluster_identifier" {
  type        = string
  description = "Aurora MySQL cluster identifier to be monitored"
  default     = "guardium-aurora-mysql"
}

variable "force_failover" {
  type        = bool
  default     = false
  description = "To failover the database cluster, requires multi AZ databases. Results in minimal downtime"
}

variable "audit_events" {
  type        = string
  description = "Comma-separated list of events to audit (CONNECT,QUERY,TABLE,QUERY_DDL,QUERY_DML,QUERY_DCL)"
  default     = "CONNECT,QUERY"
}

variable "audit_incl_users" {
  type        = string
  description = "Comma-separated list of users to include in audit logs (server_audit_incl_users). If set, only these users will be audited. Leave empty to audit all users."
  default     = ""
}

variable "audit_excl_users" {
  type        = string
  description = "Comma-separated list of users to exclude from audit logs (server_audit_excl_users). Example: 'rdsadmin,testuser'. The rdsadmin user queries the database every second for health checks, which can cause log files to grow quickly."
  default     = "rdsadmin"
}

variable "cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to CloudWatch. Valid values for Aurora MySQL: audit, error, general, slowquery"
  default     = ["audit"]
}

//////
// Guardium variables
//////

variable "udc_name" {
  type        = string
  description = "Name for universal connector. Is used for all aws objects"
  default     = "aurora-mysql-gdp"
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

variable "prefix" {
  type        = bool
  description = "This is the prefix."
  default     = false
}

variable "unmask" {
  type        = bool
  description = "This is the unmask value"
  default     = false
}
