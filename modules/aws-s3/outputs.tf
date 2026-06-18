#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "profile_csv" {
  value       = local.udc_csv
  description = "Content of the profile CSV"
}

output "udc_name" {
  value       = local.udc_name_safe
  description = "Name of the Universal Connector"
}

output "cloudwatch_log_group_name" {
  value       = local.cloudwatch_log_group_name
  description = "Name of the CloudWatch Log Group"
}

output "cloudwatch_log_group_arn" {
  value       = local.use_existing_cloudwatch_log_group ? (length(data.aws_cloudwatch_log_group.existing) > 0 ? data.aws_cloudwatch_log_group.existing[0].arn : "") : (length(aws_cloudwatch_log_group.s3_monitoring) > 0 ? aws_cloudwatch_log_group.s3_monitoring[0].arn : "")
  description = "ARN of the CloudWatch Log Group"
}

output "formatted_cloudwatch_logs_group_arn" {
  value       = var.enable_cloudtrail ? local.formatted_cloudwatch_logs_group_arn : ""
  description = "Formatted ARN of the CloudWatch Log Group for CloudTrail"
}

output "cloudtrail_name" {
  value       = local.cloudtrail_name
  description = "Name of the CloudTrail"
}

output "cloudtrail_arn" {
  value       = var.enable_cloudtrail && !local.use_existing_cloudtrail ? aws_cloudtrail.s3_monitoring[0].arn : ""
  description = "ARN of the CloudTrail (empty if using existing trail)"
}

output "s3_bucket_name" {
  value       = var.enable_cloudtrail ? aws_s3_bucket.s3_monitoring[0].bucket : ""
  description = "Name of the S3 bucket for CloudTrail logs"
}

output "s3_bucket_arn" {
  value       = var.enable_cloudtrail ? aws_s3_bucket.s3_monitoring[0].arn : ""
  description = "ARN of the S3 bucket for CloudTrail logs"
}

output "iam_role_arn" {
  value       = var.enable_cloudtrail ? aws_iam_role.s3_monitoring_role[0].arn : ""
  description = "ARN of the IAM role for CloudTrail"
}

output "aws_account_id" {
  value       = module.aws_configuration.aws_account_id
  description = "AWS Account ID"
}

output "aws_region" {
  value       = var.aws_region
  description = "AWS Region"
}