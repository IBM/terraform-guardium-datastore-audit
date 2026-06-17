#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

# Couchbase Instance Variables

variable "couchbase_instance_identifier" {
  type        = string
  description = "Unique identifier for the Couchbase instance"
}

variable "couchbase_host" {
  type        = string
  description = "Hostname or IP address of the Couchbase server"
}

variable "couchbase_port" {
  type        = string
  description = "Port number of the Couchbase web console"
  default     = "8091"
}

variable "couchbase_cluster_name" {
  type        = string
  description = "Name of the Couchbase cluster"
  default     = ""
}

variable "couchbase_admin_username" {
  type        = string
  description = "Couchbase administrator username for REST API access. Required when enable_audit_logging = true."
  default     = ""
}

variable "couchbase_admin_password" {
  type        = string
  description = "Couchbase administrator password for REST API access. Required when enable_audit_logging = true."
  sensitive   = true
  default     = ""
}

variable "couchbase_audit_log_directory" {
  type        = string
  description = "Directory path where Couchbase audit logs are stored"
  default     = "/opt/couchbase/var/lib/couchbase/logs"
}

variable "logstash_port" {
  type        = string
  description = "Port number for Logstash on Guardium server (used in Filebeat output and UDC template)"
}

variable "datasource_tag" {
  type        = string
  description = "Datasource tag for identifying the Couchbase instance in Guardium (required)"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
}

# Audit Logging Configuration

variable "enable_audit_logging" {
  type        = bool
  description = "Enable Couchbase audit logging via REST API. Set to false if audit logging is already configured."
  default     = true
}

variable "audit_log_rotate_interval" {
  type        = number
  description = "Log rotation time interval in seconds (900-604800, i.e., 15 minutes to 7 days)"
  default     = 86400
  validation {
    condition     = var.audit_log_rotate_interval >= 900 && var.audit_log_rotate_interval <= 604800
    error_message = "Audit log rotate interval must be between 900 (15 minutes) and 604800 (7 days) seconds."
  }
}

variable "audit_log_rotate_size" {
  type        = number
  description = "Log rotation size trigger in megabytes"
  default     = 20
  validation {
    condition     = var.audit_log_rotate_size > 0
    error_message = "Audit log rotate size must be greater than 0 MB."
  }
}

# Guardium Variables

variable "udc_name" {
  type        = string
  description = "Name for universal connector. If not provided, will be auto-generated"
  default     = ""
}

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

# Universal Connector Control

variable "enable_universal_connector" {
  type        = bool
  description = "Whether to enable the universal connector module. Set to false to completely disable the universal connector for a run."
  default     = true
}

# Filebeat Configuration

variable "enable_filebeat_setup" {
  type        = bool
  description = "Enable Filebeat configuration on Couchbase server. Set to false to skip Filebeat setup."
  default     = true
}

variable "server_ip" {
  type        = string
  description = "IP address or hostname of the Couchbase server. Required when enable_filebeat_setup = true or enable_audit_logging = true."
  default     = ""
}

variable "server_username" {
  type        = string
  description = "Username for SSH connection to the Couchbase server. Required when enable_filebeat_setup = true or enable_audit_logging = true."
  default     = ""
}

variable "server_password" {
  type        = string
  description = "Password for SSH connection to the Couchbase server. Required when enable_filebeat_setup = true or enable_audit_logging = true."
  sensitive   = true
  default     = ""
}

# CSV/UDC Configuration

variable "csv_description" {
  type        = string
  description = "Description for the UDC connector"
  default     = ""
}