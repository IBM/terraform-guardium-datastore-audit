#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# AWS MySQL RDS Audit Module Outputs

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = local.udc_name
}

output "cloudwatch_log_group" {
  description = "Name of the CloudWatch Log Group for audit logs"
  value       = local.log_group
}

output "parameter_group_name" {
  description = "Name of the RDS parameter group"
  value       = module.common_rds-mariadb-mysql-parameter-group.parameter_group_name
}

output "option_group_name" {
  description = "Name of the RDS option group with audit plugin"
  value       = module.common_rds-mariadb-mysql-parameter-group.option_group_name
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = local.aws_region
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = local.aws_account_id
}

output "rds_cluster_identifier" {
  description = "RDS cluster identifier"
  value       = var.mysql_rds_cluster_identifier
}

output "log_export_type" {
  description = "Type of log export"
  value       = var.log_export_type
}
