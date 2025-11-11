#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# AWS Redshift Universal Connector Module Outputs

output "profile_csv" {
  value       = local.udc_csv
  description = "Content of the profile CSV"
}

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = local.udc_name_safe
}

output "cloudwatch_log_group_connectionlog" {
  description = "Name of the CloudWatch Log Group for connection logs"
  value       = var.input_type == "cloudwatch" ? (local.use_existing_cloudwatch_log_group ? "${var.existing_cloudwatch_log_group_name}/connectionlog" : try(aws_cloudwatch_log_group.redshift_connectionlog[0].name, "")) : ""
}

output "cloudwatch_log_group_useractivitylog" {
  description = "Name of the CloudWatch Log Group for user activity logs"
  value       = var.input_type == "cloudwatch" ? (local.use_existing_cloudwatch_log_group ? "${var.existing_cloudwatch_log_group_name}/useractivitylog" : try(aws_cloudwatch_log_group.redshift_useractivitylog[0].name, "")) : ""
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = var.input_type == "s3" ? (local.use_existing_s3_bucket ? var.existing_s3_bucket_name : try(aws_s3_bucket.redshift_logs[0].bucket, "")) : ""
}

output "s3_prefix" {
  description = "Prefix for S3 objects"
  value       = var.input_type == "s3" ? local.s3_prefix : ""
}

output "parameter_group_name" {
  description = "Name of the Redshift parameter group"
  value       = var.create_parameter_group ? try(aws_redshift_parameter_group.redshift_logging[0].name, "") : ""
}

output "input_type" {
  description = "Type of input for the Universal Connector"
  value       = var.input_type
}