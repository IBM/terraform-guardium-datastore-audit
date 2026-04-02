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
  description = "Name of the Azure resource group containing the Cosmos DB account"
}

variable "cosmos_account_name" {
  type        = string
  description = "Name of the Azure Cosmos DB account to be monitored"
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
  default     = "cosmos-audit-to-eventhub"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
}

//////
// Diagnostic Settings Configuration
//////

variable "enable_data_plane_logs" {
  type        = bool
  description = "Enable DataPlaneRequests logs (CRUD operations)"
  default     = true
}

variable "enable_query_runtime_logs" {
  type        = bool
  description = "Enable QueryRuntimeStatistics logs"
  default     = true
}

variable "enable_control_plane_logs" {
  type        = bool
  description = "Enable ControlPlaneRequests logs (management operations)"
  default     = true
}

variable "enable_partition_key_logs" {
  type        = bool
  description = "Enable PartitionKeyStatistics logs"
  default     = false
}

variable "enable_partition_ru_logs" {
  type        = bool
  description = "Enable PartitionKeyRUConsumption logs"
  default     = false
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