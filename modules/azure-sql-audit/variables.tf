#
# Copyright IBM Corp. 2025
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
  description = "Name of the Azure resource group containing the SQL Server"
}

variable "sql_server_name" {
  type        = string
  description = "Name of the Azure SQL Server to be monitored"
}

variable "sql_database_name" {
  type        = string
  description = "Name of the Azure SQL Database to be monitored"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account for audit log storage"
}

variable "audit_container_name" {
  type        = string
  description = "Name of the storage container for audit logs"
  default     = "sqldbauditlogs"
}

variable "retention_in_days" {
  type        = number
  description = "Number of days to retain audit logs"
  default     = 90
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
}

//////
// JDBC Configuration
//////

variable "credential_name" {
  type        = string
  description = "Name of the JDBC credential configured in Guardium CM"
  default     = "azure-sql-jdbc-cred"
}

variable "jdbc_driver_library" {
  type        = string
  description = "Name of the JDBC driver JAR file uploaded to Guardium CM"
  default     = "mssql-jdbc-7.4.1.jre8.jar"
}

variable "enrollment_id" {
  type        = string
  description = "Azure enrollment ID for multi-tenant support"
  default     = "123456789"
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
  default     = "60"
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