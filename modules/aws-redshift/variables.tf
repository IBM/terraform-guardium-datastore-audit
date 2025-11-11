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
  default     = {
    Purpose = "guardium-redshift-uc"
    Owner   = "your-email@example.com"
  }
}

# Redshift Configuration
variable "redshift_cluster_identifier" {
  description = "Identifier of the Redshift cluster"
  type        = string
}

# Input Configuration
variable "input_type" {
  description = "Type of input for the Universal Connector (cloudwatch or s3)"
  type        = string
  default     = "cloudwatch"
  validation {
    condition     = contains(["cloudwatch", "s3"], var.input_type)
    error_message = "Input type must be either 'cloudwatch' or 's3'."
  }
}

# CloudWatch Configuration
variable "existing_cloudwatch_log_group_name" {
  description = "Name of an existing CloudWatch Log Group to use (if empty, a new one will be created)"
  type        = string
  default     = ""
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

variable "gdp_ssh_username" {
  description = "SSH username for the Guardium Data Protection server"
  type        = string
}

variable "gdp_ssh_privatekeypath" {
  description = "Path to the SSH private key for the Guardium Data Protection server"
  type        = string
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

variable "udc_aws_credential" {
  description = "AWS credential name for the Universal Connector"
  type        = string
}

variable "csv_start_position" {
  description = "Start position for the Universal Connector"
  type        = string
  default     = "beginning"
}

variable "csv_interval" {
  description = "Interval for the Universal Connector"
  type        = string
  default     = "60"
}

variable "csv_event_filter" {
  description = "Event filter for the Universal Connector"
  type        = string
  default     = ""
}

variable "codec_pattern" {
  description = "Codec pattern for the Universal Connector"
  type        = string
  default     = "((^'%%{TIMESTAMP_ISO8601:timestamp})|(^(?<action>[^:]*) \\|%%{DAY:day}\\, %%{MONTHDAY:md} %%{MONTH:month} %%{YEAR:year} %%{TIME:time}))"
}

variable "csv_description" {
  description = "Description for the Universal Connector"
  type        = string
  default     = "Redshift Universal Connector"
}

variable "csv_cluster_name" {
  description = "Cluster name for the Universal Connector"
  type        = string
  default     = "default"
}