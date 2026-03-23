#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Couchbase Capella Audit Configuration Module - Variables

#----------------------------------------
# Capella Cluster Configuration (Existing)
#----------------------------------------
variable "capella_organization_id" {
  type        = string
  description = "Existing Capella organization ID"
}

variable "capella_project_id" {
  type        = string
  description = "Existing Capella project ID containing the cluster"
}

variable "capella_cluster_id" {
  type        = string
  description = "Existing Capella cluster ID to enable auditing on"
}

variable "capella_api_host" {
  type        = string
  description = "Capella API host endpoint"
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


#----------------------------------------
# Guardium Data Protection Configuration
#----------------------------------------
variable "gdp_server" {
  type        = string
  description = "Hostname or IP address of the Guardium Data Protection server"
}

variable "gdp_port" {
  type        = string
  description = "Port for Guardium Data Protection API connection"
  default     = "8443"
}

variable "gdp_username" {
  type        = string
  description = "Username for Guardium API authentication"
}

variable "gdp_password" {
  type        = string
  description = "Password for Guardium API authentication"
  sensitive   = true
}

variable "gdp_client_id" {
  type        = string
  description = "The client ID used to create the GDP register_oauth_client client_secret"
  default     = "client4"
}

variable "gdp_client_secret" {
  type        = string
  description = "The client secret output from grdapi register_oauth_client"
  sensitive   = true
}

variable "gdp_mu_host" {
  type        = string
  description = "Comma separated list of Guardium Managed Units to deploy profile"
  default     = ""
}

#----------------------------------------
# Universal Connector Configuration
#----------------------------------------

variable "enable_universal_connector" {
  type        = bool
  description = "Whether to enable the universal connector module"
  default     = true
}

#----------------------------------------
# CSV/UDC Configuration
#----------------------------------------

variable "csv_description" {
  type        = string
  description = "Description for the UDC connector"
  default     = ""
}

variable "csv_query_interval" {
  type        = string
  description = "Query interval"
  default     = "3600"
}

variable "csv_query_length" {
  type        = string
  description = "Query length"
  default     = "3600"
}
