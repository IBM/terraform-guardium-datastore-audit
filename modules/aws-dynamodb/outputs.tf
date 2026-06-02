output "profile_csv" {
  value       = local.udc_csv
  description = "Content of the profile CSV"
}

output "udc_name" {
  value       = local.udc_name_safe
  description = "Name of the Universal Connector"
}

output "cloudwatch_log_group_name" {
  value       = local.use_existing_cloudwatch_log_group ? var.existing_cloudwatch_log_group_name : aws_cloudwatch_log_group.dynamodb_monitoring[0].name
  description = "Name of the CloudWatch Log Group"
}

output "cloudwatch_log_group_arn" {
  value       = local.use_existing_cloudwatch_log_group ? data.aws_cloudwatch_log_group.existing[0].arn : aws_cloudwatch_log_group.dynamodb_monitoring[0].arn
  description = "ARN of the CloudWatch Log Group"
}

output "formatted_cloudwatch_logs_group_arn" {
  value       = local.formatted_cloudwatch_logs_group_arn
  description = "Formatted ARN of the CloudWatch Log Group for CloudTrail"
}

output "cloudtrail_name" {
  value       = local.cloudtrail_name
  description = "Name of the CloudTrail"
}

output "cloudtrail_s3_bucket" {
  value       = local.use_existing_cloudtrail ? null : aws_s3_bucket.dynamodb_monitoring[0].bucket
  description = "Name of the S3 bucket for CloudTrail logs"
}

output "iam_role_arn" {
  value       = local.use_existing_cloudtrail ? null : aws_iam_role.dynamodb_monitoring_role[0].arn
  description = "ARN of the IAM role for CloudTrail"
}