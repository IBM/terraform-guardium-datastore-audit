# AWS DynamoDB with Universal Connector Example - Variables

#----------------------------------------
# AWS Configuration
#----------------------------------------
variable "aws_region" {
  description = "AWS region where DynamoDB is deployed"
  type        = string
  default     = "us-east-1"
}

variable "aws_partition" {
  description = "AWS partition (aws, aws-cn, aws-us-gov)"
  type        = string
  default     = "aws"
}

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
  default     = "dynamodb-gdp"
}

#----------------------------------------
# Guardium Data Protection Connection Configuration
#----------------------------------------
variable "gdp_server" {
  description = "Hostname or IP address of the Guardium Data Protection server"
  type        = string
}

variable "gdp_port" {
  description = "Port for Guardium Data Protection API connection"
  type        = number
  default     = 8443
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
}

variable "gdp_mu_host" {
  description = "Comma separated list of Guardium Managed Units to deploy profile"
  type        = string
  default     = ""
}

#----------------------------------------
# Universal Connector Configuration
#----------------------------------------
variable "udc_aws_credential" {
  description = "The name of the AWS credential stored in Guardium Central Manager"
  type        = string
}

variable "enable_universal_connector" {
  description = "Whether to enable the universal connector module"
  type        = bool
  default     = true
}

#----------------------------------------
# DynamoDB Configuration
#----------------------------------------
variable "dynamodb_tables" {
  description = "Comma separated list of DynamoDB tables to be monitored"
  type        = string
  default     = "all"
}

#----------------------------------------
# CloudTrail and CloudWatch Configuration
#----------------------------------------
variable "existing_cloudtrail_name" {
  description = "Name of an existing CloudTrail to use (if provided, the module will use this CloudTrail instead of creating a new one)"
  type        = string
  default     = ""
}

variable "existing_cloudwatch_log_group_name" {
  description = "Name of an existing CloudWatch Log Group to use (if provided, the module will use this Log Group instead of creating a new one)"
  type        = string
  default     = ""
}

#----------------------------------------
# CSV Configuration
#----------------------------------------
variable "csv_start_position" {
  description = "Start position for UDC"
  type        = string
  default     = "end"
}

variable "csv_interval" {
  description = "Polling interval for UDC"
  type        = string
  default     = "5"
}

variable "csv_event_filter" {
  description = "UDC Event filters"
  type        = string
  default     = ""
}

variable "csv_description" {
  description = "UDC description"
  type        = string
  default     = "DynamoDB Universal Connector"
}

variable "csv_cluster_name" {
  description = "UDC Kafka Cluster name"
  type        = string
  default     = ""
} 

#----------------------------------------
# Tags
#----------------------------------------
variable "tags" {
  description = "Tags to apply to resources created by this module"
  type        = map(string)
  default     = {}
}