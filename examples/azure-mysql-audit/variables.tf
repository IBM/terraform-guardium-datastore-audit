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

//////
// Event Hub variables
//////

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

variable "azure_enrollment_id" {
  type        = string
  description = "Azure Enrollment ID (optional)"
  default     = ""
}

//////
// Diagnostic Settings variables
//////

variable "diagnostic_setting_name" {
  type        = string
  description = "Name of the diagnostic setting"
  default     = "mysql-audit-to-eventhub"
}

variable "enable_mysql_audit_logs" {
  type        = bool
  description = "Enable MySQL Audit logs"
  default     = true
}

variable "audit_log_events" {
  type        = string
  description = "MySQL audit log events to capture. Options: CONNECTION (connection events), GENERAL (DML_SELECT, DML_NONSELECT, DML, DDL, DCL, ADMIN)"
  default     = "CONNECTION,GENERAL"
}

//////
// Guardium variables
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
// Universal Connector variables
//////

variable "enable_universal_connector" {
  type        = bool
  description = "Whether to enable the universal connector module. Set to false to completely disable the universal connector for a run."
  default     = true
}

variable "initial_position" {
  type        = string
  description = "Initial position for Event Hub consumer (beginning or end)"
  default     = "end"
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