#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

//////
// AWS variables
//////

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
}

//////
// OpenSearch variables
//////

variable "opensearch_domain_name" {
  type        = string
  description = "OpenSearch domain name to be monitored"
}

variable "enable_profiler_logs" {
  type        = bool
  description = "Whether to enable profiler logs in addition to audit logs"
  default     = false
}

variable "opensearch_master_username" {
  type        = string
  description = "Master username for OpenSearch domain (required to enable security plugin auditing)"
  sensitive   = true
}

variable "opensearch_master_password" {
  type        = string
  description = "Master password for OpenSearch domain (required to enable security plugin auditing)"
  sensitive   = true
}

variable "enable_security_plugin_auditing" {
  type        = bool
  description = "Whether to enable audit logging in the OpenSearch security plugin via API"
  default     = true
}

variable "audit_rest_disabled_categories" {
  type        = list(string)
  description = "List of REST audit categories to disable. All categories are enabled by default."
  default     = []
}

variable "audit_disabled_transport_categories" {
  type        = list(string)
  description = "List of Transport audit categories to disable. All categories are enabled by default."
  default     = []
}

//////
// Guardium variables
//////

variable "udc_aws_credential" {
  type        = string
  description = "Name of AWS credential defined in Guardium"
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
}

//////
// Universal Connector variables
//////

variable "enable_universal_connector" {
  type        = bool
  description = "Whether to enable the universal connector module. Set to false to completely disable the universal connector for a run."
  default     = true
}

variable "csv_start_position" {
  type        = string
  description = "Start position for UDC"
  default     = "end"
}

variable "csv_interval" {
  type        = string
  description = "Polling interval for UDC"
  default     = "5"
}

variable "codec_pattern" {
  type        = string
  description = "Codec pattern for the Universal Connector"
  default     = ""
}

variable "csv_event_filter" {
  type        = string
  description = "UDC Event filters"
  default     = ""
}

variable "use_aws_bundled_ca" {
  type        = bool
  description = "Whether to use AWS bundled CA certificates for OpenSearch connections"
  default     = true
}

variable "log_group_prefix" {
  type        = bool
  description = "Whether the log group name includes a prefix"
  default     = false
}

variable "unmask" {
  type        = bool
  description = "Whether to unmask sensitive data in audit logs"
  default     = true
}
