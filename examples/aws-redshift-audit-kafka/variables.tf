#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

//////
// AWS & Redshift variables
//////

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "guardium"
}

variable "redshift_cluster_identifier" {
  description = "Identifier of the Redshift cluster"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Purpose = "guardium-redshift-uc"
    Owner   = "your-email@example.com"
  }
}

variable "existing_cloudwatch_log_group_name" {
  description = "Name of an existing CloudWatch Log Group base name (or comma-separated list of log groups) to use (if empty, new ones will be created)"
  type        = string
  default     = ""
}

variable "cloudwatch_log_groups" {
  description = "Optional list of explicit CloudWatch log group names to monitor. If provided, overrides existing_cloudwatch_log_group_name and default generated names."
  type        = list(string)
  default     = []
}

//////
// Guardium Data Protection variables
//////

variable "gdp_server" {
  description = "Hostname or IP address of the Guardium Data Protection server"
  type        = string
}

variable "gdp_port" {
  description = "Port for the Guardium Data Protection server"
  type        = number
  default     = 8443
}

variable "gdp_username" {
  description = "Username for the Guardium Data Protection server"
  type        = string
}

variable "gdp_password" {
  description = "Password for the Guardium Data Protection server"
  type        = string
  sensitive   = true
}

variable "gdp_client_id" {
  description = "Client ID for the Guardium Data Protection server"
  type        = string
}

variable "gdp_client_secret" {
  description = "Client secret for the Guardium Data Protection server"
  type        = string
  sensitive   = true
}

variable "gdp_mu_host" {
  description = "Management Unit host for the Guardium Data Protection server"
  type        = string
  default     = "default"
}

//////
// Universal Connector variables
//////

variable "enable_universal_connector" {
  description = "Whether to enable the Universal Connector"
  type        = bool
  default     = true
}

variable "udc_name" {
  description = "Override name for the Universal Connector profile (defaults to {aws_region}-{redshift_cluster_identifier}-{aws_account_id})"
  type        = string
  default     = ""
}

variable "udc_description" {
  description = "Description for the Universal Connector profile"
  type        = string
  default     = ""
}

variable "udc_aws_credential" {
  description = "Name of the AWS credential configured in Guardium Credential Management"
  type        = string
}

//////
// Kafka / Connect 2.0 profile settings
//////

variable "kafka_cluster_name" {
  description = "Kafka cluster name configured in Guardium"
  type        = string
  default     = "kafka"
}

variable "use_elb" {
  description = "Whether to use ELB for the Kafka-based Universal Connector"
  type        = bool
  default     = false
}

variable "filter_pattern" {
  description = "CloudWatch Logs filter pattern to include or exclude log events. Default: 'None' (no filter)."
  type        = string
  default     = "None"
}

variable "database_cluster_name" {
  description = "The name of the Redshift cluster as shown in the AWS console. Defaults to redshift_cluster_identifier if not set."
  type        = string
  default     = ""
}

variable "event_delay" {
  description = "Number of minutes to delay log ingestion to allow CloudWatch to fully flush log events. Default: 15."
  type        = number
  default     = 15
}

variable "nodata_threshold_min" {
  description = "Number of minutes without incoming events before a no-traffic alert is raised. Default: 60."
  type        = number
  default     = 60
}

variable "poll_interval_sec" {
  description = "How frequently (in seconds) the connector polls CloudWatch for new log events. Default: 30."
  type        = string
  default     = "30"

  validation {
    condition     = can(regex("^([0-5]?[0-9])$", var.poll_interval_sec))
    error_message = "poll_interval_sec must be between 0 and 59 seconds."
  }
}

variable "poll_interval" {
  description = "How frequently (in minutes) the connector polls CloudWatch for new log events. Default: 0."
  type        = number
  default     = 0
}

variable "event_limit" {
  description = "Maximum number of log events fetched per CloudWatch API call. Default: 1000."
  type        = number
  default     = 1000
}

variable "timestamp_start" {
  description = "The date and time from which the connector starts polling. Leave empty to start from current time. Stored as ISO 8601."
  type        = string
  default     = ""
}

variable "unmask" {
  description = "When true, sensitive values such as SQL query text are included unmasked in the traffic data sent to Guardium. Default: false."
  type        = bool
  default     = false
}
