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

variable "udc_name" {
  type        = string
  description = "Override name for the Universal Connector profile. If not provided, defaults to {aws_region}-{opensearch_domain_name}-{aws_account_id}."
  default     = ""
}

variable "udc_description" {
  type        = string
  description = "Description for the Universal Connector"
  default     = ""
}

//////
// Kafka-specific UC variables
//////

variable "kafka_cluster_name" {
  type        = string
  description = "Kafka cluster name for Kafka-based UC"
  default     = "kafka"
}

variable "use_elb" {
  type        = bool
  description = "Whether to use ELB for Kafka-based UC"
  default     = false
}

variable "event_delay" {
  type        = number
  description = "Event delay in seconds for Kafka-based UC"
  default     = 15
}

variable "nodata_threshold_min" {
  type        = number
  description = "No data threshold in minutes for Kafka-based UC"
  default     = 60
}

variable "unmask" {
  type        = bool
  description = "Whether to unmask sensitive data in audit logs"
  default     = false
}

variable "filter_pattern" {
  type        = string
  description = "CloudWatch Logs filter pattern for filtering audit logs"
  default     = "None"
}

variable "poll_interval" {
  type        = number
  description = "Poll interval in minutes for Kafka-based UC"
  default     = 1
}

variable "event_limit" {
  type        = number
  description = "Maximum number of events to retrieve per poll for Kafka-based UC"
  default     = 1000
}

variable "start_time" {
  type        = number
  description = "Start time as epoch in milliseconds for Kafka-based UC (0 = disabled)"
  default     = 0
}