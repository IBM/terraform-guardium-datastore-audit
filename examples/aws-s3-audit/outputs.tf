#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = module.datastore-audit_aws-s3.udc_name
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail"
  value       = module.datastore-audit_aws-s3.cloudtrail_name
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = module.datastore-audit_aws-s3.cloudtrail_arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = module.datastore-audit_aws-s3.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = module.datastore-audit_aws-s3.cloudwatch_log_group_arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  value       = module.datastore-audit_aws-s3.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for CloudTrail logs"
  value       = module.datastore-audit_aws-s3.s3_bucket_arn
}

output "iam_role_arn" {
  description = "ARN of the IAM role for CloudTrail"
  value       = module.datastore-audit_aws-s3.iam_role_arn
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = module.datastore-audit_aws-s3.aws_account_id
}

output "aws_region" {
  description = "AWS Region"
  value       = module.datastore-audit_aws-s3.aws_region
}
