#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

//////
// Azure variables
//////

variable "azure_region" {
  type        = string
  description = "Azure region where resources are deployed"
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure resource group containing the MySQL server"
}

variable "mysql_server_name" {
  type        = string
  description = "Name of the Azure MySQL Flexible Server to be monitored"
}

variable "eventhub_namespace_name" {
  type        = string
  description = "Name of the Event Hub namespace for audit log streaming"
}

variable "eventhub_name" {
  type        = string
  description = "Name of the Event Hub for audit log streaming"
}

variable "eventhub_authorization_rule_name" {
  type        = string
  description = "Name of the Event Hub namespace authorization rule"
  default     = "RootManageSharedAccessKey"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account for Event Hub checkpointing"
}

variable "consumer_group" {
  type        = string
  description = "Event Hub consumer group name"
  default     = "$Default"
}

variable "diagnostic_setting_name" {
  type        = string
  description = "Name of the diagnostic setting"
  default     = "mysql-audit-to-eventhub"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
}

variable "azure_enrollment_id" {
  type        = string
  description = "Azure Enterprise Agreement enrollment ID (optional, hidden field in Guardium UI)"
  default     = ""
}

//////
// Diagnostic Settings Configuration
//////

variable "enable_mysql_audit_logs" {
  type        = bool
  description = "Enable MySQL Audit logs"
  default     = true
}

variable "enable_slow_query_logs" {
  type        = bool
  description = "Enable MySQL Slow Query logs"
  default     = false
}

variable "audit_log_events" {
  type        = string
  description = "MySQL audit log events to capture. Options: CONNECTION (connection events), GENERAL (DML_SELECT, DML_NONSELECT, DML, DDL, DCL, ADMIN)"
  default     = "CONNECTION,GENERAL"
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
  description = "Start position for UDC (beginning or end)"
  default     = "end"
}

variable "csv_interval" {
  type        = string
  description = "Polling interval for UDC in seconds"
  default     = "5"
}

variable "csv_event_filter" {
  type        = string
  description = "UDC Event filters"
  default     = ""
}

variable "codec_pattern" {
  type        = string
  description = "Codec pattern for the Universal Connector"
  default     = ""
}

//////
// Event Hub Advanced Configuration
//////

variable "config_mode" {
  type        = string
  description = "Configuration mode for Event Hub input (basic or advanced)"
  default     = "basic"
}

variable "threads" {
  type        = number
  description = "Number of threads for Event Hub consumer"
  default     = 8
}

variable "decorate_events" {
  type        = bool
  description = "Whether to decorate events with Event Hub metadata"
  default     = true
}