# AWS DynamoDB with Universal Connector Example - Outputs

#----------------------------------------
# Universal Connector Outputs
#----------------------------------------
output "profile_csv" {
  value       = module.datastore-audit_aws-dynamodb.profile_csv
  description = "Content of the profile CSV"
}

output "udc_name" {
  value       = module.datastore-audit_aws-dynamodb.udc_name
  description = "Name of the Universal Connector"
}

#----------------------------------------
# CloudWatch and CloudTrail Outputs
#----------------------------------------
output "cloudwatch_log_group_name" {
  value       = module.datastore-audit_aws-dynamodb.cloudwatch_log_group_name
  description = "Name of the CloudWatch Log Group"
}

output "cloudwatch_log_group_arn" {
  value       = module.datastore-audit_aws-dynamodb.cloudwatch_log_group_arn
  description = "ARN of the CloudWatch Log Group"
}

output "formatted_cloudwatch_logs_group_arn" {
  value       = module.datastore-audit_aws-dynamodb.formatted_cloudwatch_logs_group_arn
  description = "Formatted ARN of the CloudWatch Log Group for CloudTrail"
}

output "cloudtrail_name" {
  value       = module.datastore-audit_aws-dynamodb.cloudtrail_name
  description = "Name of the CloudTrail"
}

output "cloudtrail_s3_bucket" {
  value       = module.datastore-audit_aws-dynamodb.cloudtrail_s3_bucket
  description = "Name of the S3 bucket for CloudTrail logs"
}

output "iam_role_arn" {
  value       = module.datastore-audit_aws-dynamodb.iam_role_arn
  description = "ARN of the IAM role for CloudTrail"
}

#----------------------------------------
# Configuration Outputs
#----------------------------------------
output "aws_region" {
  description = "AWS region where DynamoDB is deployed"
  value       = var.aws_region
}

output "dynamodb_tables" {
  description = "DynamoDB tables being monitored"
  value       = var.dynamodb_tables
}

output "gdp_server" {
  description = "Hostname of the Guardium Data Protection server"
  value       = var.gdp_server
}

output "universal_connector_enabled" {
  description = "Whether the Universal Connector is enabled"
  value       = var.enable_universal_connector
}
