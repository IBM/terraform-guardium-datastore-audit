#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "cloudwatch_log_group_audit" {
  description = "Name of the CloudWatch Log Group for audit logs"
  value       = aws_cloudwatch_log_group.audit_log_group.name
}

output "cloudwatch_log_group_audit_arn" {
  description = "ARN of the CloudWatch Log Group for audit logs"
  value       = aws_cloudwatch_log_group.audit_log_group.arn
}

output "cloudwatch_log_group_profiler" {
  description = "Name of the CloudWatch Log Group for profiler logs"
  value       = var.enable_profiler_logs ? aws_cloudwatch_log_group.profiler_log_group[0].name : null
}

output "cloudwatch_log_group_profiler_arn" {
  description = "ARN of the CloudWatch Log Group for profiler logs"
  value       = var.enable_profiler_logs ? aws_cloudwatch_log_group.profiler_log_group[0].arn : null
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = local.aws_region
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = local.aws_account_id
}

output "opensearch_domain_name" {
  description = "OpenSearch domain name"
  value       = var.opensearch_domain_name
}

output "opensearch_domain_endpoint" {
  description = "OpenSearch domain endpoint"
  value       = "https://${aws_opensearch_domain.audit.endpoint}"
}

output "opensearch_domain_arn" {
  description = "OpenSearch domain ARN"
  value       = aws_opensearch_domain.audit.arn
}

output "opensearch_dashboard_url" {
  description = "OpenSearch Dashboard URL"
  value       = "https://${aws_opensearch_domain.audit.dashboard_endpoint}"
}
