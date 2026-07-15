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
  description = "Name of the Azure resource group containing the Databricks workspace and Event Hub"
}

variable "databricks_workspace_name" {
  type        = string
  description = "Name of the Azure Databricks workspace to be monitored"
}

variable "databricks_workspace_resource_id" {
  type        = string
  description = "Full Azure resource ID of the Databricks workspace (used to attach diagnostic settings)"
}

variable "azure_enrollment_id" {
  type        = string
  description = "Azure Enrollment ID"
  default     = ""
}

//////
// Databricks UC version
//////

variable "uc_version" {
  type        = string
  description = "Databricks Universal Connector version. Use 'uc1' for standard workspace auditing or 'uc2' for Unity Catalog auditing (adds unityCatalog log category and uses the Unity Catalog profile definition name)"
  default     = "uc1"

  validation {
    condition     = contains(["uc1", "uc2"], var.uc_version)
    error_message = "uc_version must be either 'uc1' (standard workspace) or 'uc2' (Unity Catalog)."
  }
}

//////
// Event Hub Configuration
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
  description = "Name of the hub-level authorization rule used to build the UC Event Hub connection string"
  default     = "RootManageSharedAccessKey"
}

variable "eventhub_namespace_authorization_rule_name" {
  type        = string
  description = "Name of the namespace-level authorization rule used by the Azure Monitor diagnostic setting (must be a namespace rule, not a hub rule)"
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
  description = "Name of the Azure Monitor diagnostic setting"
  default     = "databricks-audit-to-eventhub"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
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

variable "udc_name" {
  type        = string
  description = "Base name override for the Universal Connector profile. The subscription ID is always appended. If not provided, defaults to {databricks_workspace_name}-databricks-{subscription_id}."
  default     = ""
}

variable "udc_description" {
  type        = string
  description = "Description for the Universal Connector profile. Defaults to an auto-generated description based on uc_version and workspace name."
  default     = ""
}

variable "udc_credential" {
  type        = string
  description = "Name of the credential configured in Guardium CM for this Universal Connector"
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

//////
// UC 2.0-specific variables
//////

variable "gdp_cluster_name" {
  type        = string
  description = "Guardium cluster/group name to assign the UC 2.0 profile to. Must already exist in Guardium CM. Leave empty to not assign to a cluster."
  default     = ""
}


variable "mu_count" {
  type        = number
  description = "Number of Managed Units to deploy the UC 2.0 profile to"
  default     = 2
}

variable "use_elb" {
  type        = bool
  description = "Whether to use ELB (UC 2.0)"
  default     = false
}

variable "eventhub_partition_count" {
  type        = number
  description = "Number of Event Hub partitions (UC 2.0)"
  default     = 4
}

variable "start_time" {
  type        = number
  description = "Start time as epoch in milliseconds (UC 2.0, 0 = disabled)"
  default     = 0
}

variable "nodata_threshold_min" {
  type        = number
  description = "No data threshold in minutes (UC 2.0)"
  default     = 60
}
