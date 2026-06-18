#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Couchbase Capella Audit Configuration Example - Variables

#----------------------------------------
# Capella Cluster Configuration (Existing)
#----------------------------------------
variable "capella_organization_id" {
  description = "Existing Capella organization ID"
  type        = string
}

variable "capella_project_id" {
  description = "Existing Capella project ID"
  type        = string
}

variable "capella_cluster_id" {
  description = "Existing Capella cluster ID"
  type        = string
}

variable "capella_api_host" {
  description = "Capella API host endpoint"
  type        = string
  default     = "https://cloudapi.cloud.couchbase.com"
}

variable "capella_api_token" {
  description = "API token for authentication"
  type        = string
  sensitive   = true
}

variable "auditlogsettings" {
  description = "configure cluster audit log settings"

  type = object({
    audit_enabled     = bool
    enabled_event_ids = list(number)
    disabled_users = list(object({
      name   = string
      domain = string
    }))
  })
}

variable "csv_description" {
  type        = string
  description = "Description for the UDC connector"
  default     = ""
}

variable "csv_query_interval" {
  type        = string
  description = "??"
  default     = "3600"
}

variable "csv_query_length" {
  type        = string
  description = "??"
  default     = "3600"
}

#----------------------------------------
# Guardium Data Protection Configuration
#----------------------------------------
variable "gdp_server" {
  description = "Hostname or IP address of the Guardium Data Protection server"
  type        = string
}

variable "gdp_port" {
  description = "Port for Guardium Data Protection API connection"
  type        = string
  default     = "8443"
}

variable "gdp_username" {
  description = "Username for Guardium API authentication"
  type        = string
}

variable "gdp_password" {
  description = "Password for Guardium API authentication"
  type        = string
  sensitive   = true
}

variable "gdp_client_id" {
  description = "The client ID used to create the GDP register_oauth_client client_secret"
  type        = string
  default     = "client4"
}

variable "gdp_client_secret" {
  description = "The client secret output from grdapi register_oauth_client"
  type        = string
  sensitive   = true
}

variable "gdp_mu_host" {
  description = "Comma separated list of Guardium Managed Units to deploy profile"
  type        = string
  default     = ""
}

#----------------------------------------
# Universal Connector Configuration
#----------------------------------------

variable "enable_universal_connector" {
  description = "Whether to enable the universal connector module"
  type        = bool
  default     = true
}
