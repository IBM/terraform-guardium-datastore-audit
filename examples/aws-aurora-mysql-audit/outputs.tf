#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# AWS Aurora MySQL Audit Example Outputs

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = module.datastore-audit_aws-aurora-mysql.udc_name
}

output "log_group" {
  description = "CloudWatch log group(s) being monitored"
  value       = module.datastore-audit_aws-aurora-mysql.log_group
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = module.datastore-audit_aws-aurora-mysql.aws_region
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = module.datastore-audit_aws-aurora-mysql.aws_account_id
}

output "aurora_mysql_cluster_identifier" {
  description = "Aurora MySQL cluster identifier"
  value       = var.aurora_mysql_cluster_identifier
}

output "cloudwatch_logs_exports" {
  description = "CloudWatch log types being exported"
  value       = var.cloudwatch_logs_exports
}