#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "profile_csv" {
  description = "Universal Connector profile CSV"
  value       = var.enable_universal_connector ? module.gdp_connect-datasource-to-uc[0].profile_csv : "Universal connector disabled"
}

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = local.udc_name
}

output "parameter_group_name" {
  description = "Name of the Neptune cluster parameter group"
  value       = aws_neptune_cluster_parameter_group.guardium.name
}

output "cloudwatch_log_group" {
  description = "Name of the CloudWatch Log Group for audit logs"
  value       = format("/aws/neptune/%s/audit", var.neptune_cluster_identifier)
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = local.aws_region
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = local.aws_account_id
}

output "neptune_cluster_identifier" {
  description = "Neptune cluster identifier"
  value       = var.neptune_cluster_identifier
}

output "neptune_cluster_endpoint" {
  description = "Neptune cluster endpoint"
  value       = var.neptune_endpoint
}