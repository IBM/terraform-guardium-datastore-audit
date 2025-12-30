//////
// AWS variables
//////

variable "aws_region" {
  type        = string
  description = "This is the AWS region."
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for resources"
  default     = "dynamodb-gdp"
}

variable "aws_partition" {
  type        = string
  description = "AWS partition (aws, aws-cn, aws-us-gov)"
  default     = "aws"
}

//////
// Guardium variables
//////

variable "udc_aws_credential" {
  type        = string
  description = "The name of the AWS credential stored in Guardium Central Manager"
}

variable "gdp_client_secret" {
  type        = string
  description = "The client secret output from grdapi register_oauth_client"
}

variable "gdp_client_id" {
  type        = string
  description = "The client ID for Guardium authentication"
  default     = "client4"
}


variable "gdp_server" {
  type        = string
  description = "The hostname or IP address of the Guardium server"
}

variable "gdp_port" {
  type        = string
  description = "The port of the Guardium server"
  default     = "8443"
}

variable "gdp_username" {
  type        = string
  description = "The username to login to Guardium"
}

variable "gdp_password" {
  type        = string
  description = "The password for logging in to Guardium"
  sensitive   = true
}



variable "gdp_mu_host" {
  type        = string
  description = "Comma separated list of Guardium Managed Units to deploy profile"
  default     = ""
}

variable "enable_universal_connector" {
  type        = bool
  description = "Whether to enable the universal connector module. Set to false to completely disable the universal connector for a run."
  default     = true
}

//////
// CSV configuration variables
//////

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

variable "csv_event_filter" {
  type        = string
  description = "UDC Event filters"
  default     = ""
}

variable "csv_description" {
  type        = string
  description = "UDC description"
  default     = ""
}

variable "csv_cluster_name" {
  type        = string
  description = "UDC Kafka Cluster name"
  default     = ""
}

variable "dynamodb_tables" {
  type        = string
  description = "Comma separated list of DynamoDB tables to be monitored"
  default     = "testing"
}

# Variables for CloudTrail and CloudWatch Log Group
variable "aws_log_group" {
  type        = string
  description = "Name of the CloudWatch log group where CloudTrail logs will be stored"
  default     = "dynamodb-logs"
}

variable "create_cloudtrail_s3_bucket" {
  type        = bool
  description = "Whether to create a new S3 bucket for CloudTrail logs"
  default     = true
}

# Variables for using existing CloudTrail and CloudWatch Log Group
variable "existing_cloudtrail_name" {
  type        = string
  description = "Name of an existing CloudTrail to use (if provided, the module will use this CloudTrail instead of creating a new one)"
  default     = ""
}

variable "existing_cloudwatch_log_group_name" {
  type        = string
  description = "Name of an existing CloudWatch Log Group to use (if provided, the module will use this Log Group instead of creating a new one)"
  default     = ""
}



variable "endpoint" {
  type        = string
  description = "Custom endpoint URL for AWS CloudWatch"
  default     = ""
}

variable "use_aws_bundled_ca" {
  type        = bool
  description = "Whether to use the AWS bundled CA certificates"
  default     = true
}

