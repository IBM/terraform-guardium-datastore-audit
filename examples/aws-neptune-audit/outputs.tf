#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# AWS Neptune Audit Example Outputs

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = module.datastore-audit_aws-neptune-audit.udc_name
}

output "cloudwatch_log_group" {
  description = "Name of the CloudWatch Log Group for audit logs"
  value       = module.datastore-audit_aws-neptune-audit.cloudwatch_log_group
}

output "parameter_group_name" {
  description = "Name of the Neptune cluster parameter group"
  value       = module.datastore-audit_aws-neptune-audit.parameter_group_name
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = module.datastore-audit_aws-neptune-audit.aws_region
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = module.datastore-audit_aws-neptune-audit.aws_account_id
}

output "neptune_cluster_identifier" {
  description = "Neptune cluster identifier"
  value       = module.datastore-audit_aws-neptune-audit.neptune_cluster_identifier
}

output "neptune_cluster_endpoint" {
  description = "Neptune cluster endpoint"
  value       = module.datastore-audit_aws-neptune-audit.neptune_cluster_endpoint
}

output "reboot_required" {
  description = "Whether manual reboot is required to enable audit logging"
  value       = module.datastore-audit_aws-neptune-audit.reboot_required
}