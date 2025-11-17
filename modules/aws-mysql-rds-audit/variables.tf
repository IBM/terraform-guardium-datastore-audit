#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

//////
// AWS variables
//////

variable "aws_region" {
  type        = string
  description = "This is the AWS region."
  default     = "us-east-2"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
}

variable "mysql_rds_cluster_identifier" {
  type        = string
  default     = "guardium-mysql"
  description = "MySQL RDS cluster identifier to be monitored"
}

variable "force_failover" {
  type        = bool
  default     = false
  description = "To failover the database instance, requires multi AZ databases. Results in minimal downtime"
}

variable "mysql_major_version" {
  type        = string
  description = "Major version of MySQL (e.g., '5.7')"
  default     = "5.7"
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

//////
// General variables
//////
variable "udc_name" {
  type        = string
  description = "Name for universal connector. Is used for all aws objects"
  default     = "mysql-gdp"
}


variable "udc_aws_credential" {
  type        = string
  description = "name of AWS credential defined in Guardium"
}

variable "gdp_client_secret" {
  type        = string
  description = "Client secret from output of grdapi register_oauth_client"
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

variable "gdp_ssh_username" {
  type        = string
  description = "Guardium OS user with SSH access"
}

variable "gdp_ssh_privatekeypath" {
  type        = string
  description = "Private SSH key to connect to Guardium OS with ssh username"
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
  default = "Cloudwatch"

  validation {
    condition = var.log_export_type == "Cloudwatch"
    error_message = "log_export_type must be 'Cloudwatch'"
  }
}

