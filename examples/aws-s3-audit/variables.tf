#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# AWS S3 Audit Example Variables

######
# General Configuration
######

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "guardium-s3"
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
    Purpose = "guardium-s3-uc"
    Owner   = "your-email@example.com"
  }
}

######
# CloudTrail Configuration
######

variable "enable_cloudtrail" {
  description = "Whether to enable CloudTrail for S3 audit logging"
  type        = bool
  default     = true
}

variable "existing_cloudtrail_name" {
  description = "Name of an existing CloudTrail to use (leave empty to create new)"
  type        = string
  default     = ""
}

variable "existing_cloudwatch_log_group_name" {
  description = "Name of an existing CloudWatch Log Group to use (leave empty to create new)"
  type        = string
  default     = ""
}

variable "force_destroy_bucket" {
  description = "Whether to force destroy the S3 bucket (allows deletion with objects)"
  type        = bool
  default     = false
}

variable "cloudwatch_logs_retention_days" {
  description = "Number of days to retain CloudWatch Logs"
  type        = number
  default     = 7
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs to monitor (use [\"arn:aws:s3\"] for all buckets, or specific bucket ARNs like [\"arn:aws:s3:::bucket-name/\"] for individual buckets)"
  type        = list(string)
  default     = ["arn:aws:s3"]
}

variable "include_global_service_events" {
  description = "Whether to include global service events in CloudTrail"
  type        = bool
  default     = false
}

variable "is_multi_region_trail" {
  description = "Whether the trail is multi-region"
  type        = bool
  default     = false
}

variable "include_management_events" {
  description = "Whether to include management events in CloudTrail"
  type        = bool
  default     = false
}

######
# Guardium Data Protection Configuration
######

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
  description = "Comma-separated list of Guardium Managed Units"
  type        = string
  default     = ""
}

######
# Universal Connector Configuration
######

variable "enable_universal_connector" {
  description = "Whether to enable the Universal Connector"
  type        = bool
  default     = true
}

variable "udc_aws_credential" {
  description = "AWS credential name stored in Guardium Central Manager"
  type        = string
}

variable "udc_start_position" {
  description = "Start position for reading logs (beginning/end)"
  type        = string
  default     = "end"
}

variable "udc_interval" {
  description = "Interval for polling CloudWatch Logs (in seconds)"
  type        = string
  default     = "5"
}

variable "udc_event_filter" {
  description = "CloudWatch Logs filter pattern for S3 events"
  type        = string
  default     = "{$.eventSource=\"s3.amazonaws.com\"}"
}

variable "udc_description" {
  description = "Description for the Universal Connector"
  type        = string
  default     = "S3 Universal Connector via CloudTrail"
}

variable "udc_prefix" {
  description = "Prefix for log filtering"
  type        = bool
  default     = false
}

variable "udc_unmask" {
  description = "Whether to unmask sensitive data"
  type        = bool
  default     = false
}

variable "udc_endpoint" {
  description = "Custom endpoint URL for AWS CloudWatch"
  type        = string
  default     = ""
}

variable "udc_use_aws_bundled_ca" {
  description = "Whether to use AWS bundled CA certificates"
  type        = bool
  default     = true
}
