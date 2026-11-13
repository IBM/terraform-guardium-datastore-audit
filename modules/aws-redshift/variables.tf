#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# AWS Redshift Universal Connector Module Variables

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "guardium"
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Purpose = "guardium-redshift-uc"
    Owner   = "your-email@example.com"
  }
}

# Redshift Configuration
variable "redshift_cluster_identifier" {
  description = "Identifier of the Redshift cluster"
  type        = string
}

# Universal Connector Mode
variable "uc_mode" {
  description = "Universal Connector mode: logstash or kafka"
  type        = string
  default     = "logstash"

  validation {
    condition     = contains(["logstash", "kafka"], var.uc_mode)
    error_message = "uc_mode must be either 'logstash' or 'kafka'."
  }
}

# Input Configuration (for logstash mode)
variable "input_type" {
  description = "Type of input for the Universal Connector in logstash mode (cloudwatch or s3)"
  type        = string
  default     = "cloudwatch"
  validation {
    condition     = contains(["cloudwatch", "s3"], var.input_type)
    error_message = "Input type must be either 'cloudwatch' or 's3'."
  }
}

# CloudWatch Configuration
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

# S3 Configuration
variable "existing_s3_bucket_name" {
  description = "Name of an existing S3 bucket to use (if empty, a new one will be created)"
  type        = string
  default     = ""
}

variable "s3_prefix" {
  description = "Prefix for S3 objects (if using S3 input)"
  type        = string
  default     = ""
}

# Parameter Group Configuration
variable "create_parameter_group" {
  description = "Whether to create a parameter group for Redshift logging"
  type        = bool
  default     = true
}

variable "existing_parameter_group_name" {
  description = "Name of an existing parameter group to use (if empty, a new one will be created)"
  type        = string
  default     = ""
}

variable "enable_logging" {
  description = "Whether to enable logging for the Redshift cluster"
  type        = bool
  default     = true
}

variable "enable_audit_setup" {
  description = "Whether to configure the Redshift cluster for audit logging (parameter group + CloudWatch log exports). Set to false to skip all AWS-side audit setup and only manage the Universal Connector."
  type        = bool
  default     = true
}

# Guardium Data Protection Configuration
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

# Universal Connector Configuration
variable "enable_universal_connector" {
  description = "Whether to enable the Universal Connector"
  type        = bool
  default     = true
}

variable "udc_name" {
  description = "Override name for the Universal Connector profile. If not provided, defaults to {aws_region}-{redshift_cluster_identifier}-{aws_account_id}."
  type        = string
  default     = ""
}

variable "udc_description" {
  description = "Description for the Universal Connector profile. If not provided, an auto-generated description is used."
  type        = string
  default     = ""
}

variable "udc_aws_credential" {
  description = "AWS credential name for the Universal Connector"
  type        = string
}

# Logstash Mode Variables
variable "csv_start_position" {
  description = "Start position for the Universal Connector (logstash mode)"
  type        = string
  default     = "beginning"
}

variable "csv_interval" {
  description = "Interval for the Universal Connector (logstash mode)"
  type        = string
  default     = "60"
}

variable "csv_event_filter" {
  description = "Event filter for the Universal Connector (logstash mode)"
  type        = string
  default     = ""
}

variable "codec_pattern" {
  description = "Codec pattern for the Universal Connector (logstash mode)"
  type        = string
  default     = "((^'%%{TIMESTAMP_ISO8601:timestamp})|(^(?<action>[^:]*) \\|%%{DAY:day}\\, %%{MONTHDAY:md} %%{MONTH:month} %%{YEAR:year} %%{TIME:time}))"
}

variable "csv_description" {
  description = "Legacy description for the Universal Connector"
  type        = string
  default     = "Redshift Universal Connector"
}

variable "csv_cluster_name" {
  description = "Cluster name for the Universal Connector (logstash mode)"
  type        = string
  default     = "default"
}

variable "cloudwatch_endpoint" {
  type        = string
  description = "Custom endpoint URL for AWS CloudWatch"
  default     = ""
}

variable "use_aws_bundled_ca" {
  type        = bool
  description = "Whether to use the AWS bundled CA certificates"
  default     = true
}

# Kafka Mode Variables (AWS Redshift Over Cloudwatch Connect 2.0)
variable "kafka_cluster_name" {
  type        = string
  description = "Kafka cluster name configured in Guardium"
  default     = "kafka"
}

variable "use_elb" {
  type        = bool
  description = "Whether to use ELB for the Kafka-based Universal Connector"
  default     = false
}

variable "filter_pattern" {
  type        = string
  description = "CloudWatch Logs filter pattern to include or exclude log events. Default: 'None' (no filter)."
  default     = "None"
}

variable "database_cluster_name" {
  type        = string
  description = "The name of the Redshift cluster as shown in the AWS console. Defaults to redshift_cluster_identifier if not set."
  default     = ""
}

variable "event_delay" {
  type        = number
  description = "Number of minutes to delay log ingestion to allow CloudWatch to fully flush log events. Default: 15."
  default     = 15
}

variable "nodata_threshold_min" {
  type        = number
  description = "Number of minutes without incoming events before a no-traffic alert is raised. Default: 60."
  default     = 60
}

variable "poll_interval_sec" {
  type        = string
  description = "How frequently (in seconds) the connector polls CloudWatch for new log events. Default: 30."
  default     = "30"

  validation {
    condition     = can(regex("^([0-5]?[0-9])$", var.poll_interval_sec))
    error_message = "poll_interval_sec must be between 0 and 59 seconds."
  }
}

variable "poll_interval" {
  type        = number
  description = "How frequently (in minutes) the connector polls CloudWatch for new log events. Default: 0."
  default     = 0
}

variable "event_limit" {
  type        = number
  description = "Maximum number of log events fetched per CloudWatch API call. Default: 1000."
  default     = 1000
}

variable "timestamp_start" {
  type        = string
  description = "The date and time from which the connector starts polling. Leave empty to start from current time. Stored as ISO 8601."
  default     = ""
}

variable "unmask" {
  type        = bool
  description = "When true, sensitive values such as SQL query text are included unmasked in the traffic data sent to Guardium. Default: false."
  default     = false
}
