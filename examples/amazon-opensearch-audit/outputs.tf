#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# AWS OpenSearch Audit Example Outputs

output "cloudwatch_log_group_audit" {
  description = "Name of the CloudWatch Log Group for audit logs"
  value       = module.datastore-audit_amazon-opensearch-audit.cloudwatch_log_group_audit
}

output "cloudwatch_log_group_audit_arn" {
  description = "ARN of the CloudWatch Log Group for audit logs"
  value       = module.datastore-audit_amazon-opensearch-audit.cloudwatch_log_group_audit_arn
}

output "cloudwatch_log_group_profiler" {
  description = "Name of the CloudWatch Log Group for profiler logs"
  value       = module.datastore-audit_amazon-opensearch-audit.cloudwatch_log_group_profiler
}

output "cloudwatch_log_group_profiler_arn" {
  description = "ARN of the CloudWatch Log Group for profiler logs"
  value       = module.datastore-audit_amazon-opensearch-audit.cloudwatch_log_group_profiler_arn
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = module.datastore-audit_amazon-opensearch-audit.aws_region
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = module.datastore-audit_amazon-opensearch-audit.aws_account_id
}

output "opensearch_domain_name" {
  description = "OpenSearch domain name"
  value       = module.datastore-audit_amazon-opensearch-audit.opensearch_domain_name
}

output "opensearch_domain_endpoint" {
  description = "OpenSearch domain endpoint"
  value       = module.datastore-audit_amazon-opensearch-audit.opensearch_domain_endpoint
}

output "opensearch_domain_arn" {
  description = "OpenSearch domain ARN"
  value       = module.datastore-audit_amazon-opensearch-audit.opensearch_domain_arn
}

output "opensearch_dashboard_url" {
  description = "OpenSearch Dashboard URL"
  value       = module.datastore-audit_amazon-opensearch-audit.opensearch_dashboard_url
}
