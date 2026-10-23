#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

//////
// CSV input
//////

variable "csv_file_paths" {
  type        = list(string)
  description = "List of paths to Universal Connector profile CSV files to import into Guardium. Each file is uploaded separately; profile names are extracted automatically from all files and deduplicated."

  validation {
    condition     = length(var.csv_file_paths) > 0
    error_message = "csv_file_paths must contain at least one file path."
  }
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
// Universal Connector Control
//////

variable "enable_universal_connector" {
  type        = bool
  description = "Whether to enable the universal connector module. Set to false to skip profile import and deployment for a run."
  default     = true
}

variable "test_connections" {
  type        = bool
  description = "Test connections after import. Guardium only tests profiles that support it (Kafka Connect-based, UC 2.0, e.g. Snowflake Over JDBC Connect 2.0); other profiles are ignored. A profile whose test fails is not deployed, and the other profiles are still deployed. Defaults to true."
  default     = true
}
