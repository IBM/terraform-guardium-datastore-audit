#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# AWS MySQL RDS Audit Example Outputs

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = module.datastore-audit_aws-mysql-rds-audit.udc_name
}

output "cloudwatch_log_group" {
  description = "Name of the CloudWatch Log Group for audit logs"
  value       = module.datastore-audit_aws-mysql-rds-audit.cloudwatch_log_group
}

output "parameter_group_name" {
  description = "Name of the RDS parameter group"
  value       = module.datastore-audit_aws-mysql-rds-audit.parameter_group_name
}

output "option_group_name" {
  description = "Name of the RDS option group with audit plugin"
  value       = module.datastore-audit_aws-mysql-rds-audit.option_group_name
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = module.datastore-audit_aws-mysql-rds-audit.aws_region
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = module.datastore-audit_aws-mysql-rds-audit.aws_account_id
}

output "rds_cluster_identifier" {
  description = "RDS cluster identifier"
  value       = module.datastore-audit_aws-mysql-rds-audit.rds_cluster_identifier
}

output "log_export_type" {
  description = "Type of log export"
  value       = module.datastore-audit_aws-mysql-rds-audit.log_export_type
}
