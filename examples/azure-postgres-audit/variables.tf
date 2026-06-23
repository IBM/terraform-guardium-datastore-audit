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

variable "azure_enrollment_id" {
  description = "Azure Enrollment ID (required)"
  type        = string
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure resource group containing the PostgreSQL server"
}

variable "postgres_server_name" {
  type        = string
  description = "Name of the Azure PostgreSQL Flexible Server to be monitored"
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

variable "firewall_rules" {
  type = map(object({
    start_ip = string
    end_ip   = string
  }))
  description = "Map of PostgreSQL firewall rules to create (name => {start_ip, end_ip})"
  default     = {}
}

//////
// Diagnostic Settings variables
//////

variable "diagnostic_setting_name" {
  type        = string
  description = "Name of the diagnostic setting"
  default     = "postgres-audit-to-eventhub"
}

//////
// PostgreSQL pgAudit Configuration
//////

variable "pgaudit_log" {
  type        = string
  description = "Specifies which classes of statements will be logged by pgAudit. Options: READ, WRITE, FUNCTION, ROLE, DDL, MISC, ALL"
  default     = "DDL,FUNCTION,READ,WRITE,ROLE"
}

variable "pgaudit_log_catalog" {
  type        = bool
  description = "Specifies whether session audit logging should create a separate log entry for statements in the PostgreSQL catalog"
  default     = false
}

variable "pgaudit_log_client" {
  type        = bool
  description = "Specifies whether audit messages should be visible to the client"
  default     = false
}

variable "pgaudit_log_parameter" {
  type        = bool
  description = "Specifies whether parameters should be included in the audit log"
  default     = false
}

variable "log_checkpoints" {
  type        = bool
  description = "Causes checkpoints and restartpoints to be logged in the server log"
  default     = false
}

variable "log_error_verbosity" {
  type        = string
  description = "Controls the amount of detail written in the server log for each message. Valid values: TERSE, DEFAULT, VERBOSE"
  default     = "VERBOSE"
}

variable "log_line_prefix" {
  type        = string
  description = "Controls information prefixed to each log line. Example: %t:%r:%u@%d:[%p]:%a:%e"
  default     = "%t:%r:%u@%d:[%p]:%a:%e"
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
