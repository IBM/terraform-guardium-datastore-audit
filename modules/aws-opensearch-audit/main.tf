#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  udc_name       = format("%s-%s-%s", var.aws_region, var.opensearch_domain_name, local.aws_account_id)
  aws_partition  = data.aws_partition.current.partition
  aws_region     = data.aws_region.current.id
  aws_account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

# Get the existing OpenSearch domain
data "aws_opensearch_domain" "existing" {
  domain_name = var.opensearch_domain_name
}

# CloudWatch Log Group for OpenSearch audit logs
resource "aws_cloudwatch_log_group" "opensearch_audit" {
  name              = "/aws/OpenSearchService/${var.opensearch_domain_name}/audit"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# CloudWatch Log Group for OpenSearch profiler logs (optional)
resource "aws_cloudwatch_log_group" "opensearch_profiler" {
  count             = var.enable_profiler_logs ? 1 : 0
  name              = "/aws/OpenSearchService/${var.opensearch_domain_name}/profiler"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# IAM policy for OpenSearch to write to CloudWatch Logs
data "aws_iam_policy_document" "opensearch_log_publishing_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
    ]
    resources = [
      "${aws_cloudwatch_log_group.opensearch_audit.arn}:*"
    ]
  }
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_log_publishing_policy" {
  policy_name     = "opensearch-${var.opensearch_domain_name}-audit-log-policy"
  policy_document = data.aws_iam_policy_document.opensearch_log_publishing_policy.json
}

# Enable audit logging on the OpenSearch domain using GDP middleware helper
resource "gdp-middleware-helper_opensearch_modify" "enable_audit_logs" {
  depends_on = [
    aws_cloudwatch_log_group.opensearch_audit,
    aws_cloudwatch_log_resource_policy.opensearch_log_publishing_policy
  ]

  domain_name          = var.opensearch_domain_name
  region               = var.aws_region
  audit_logs_enabled   = true
  audit_logs_group_arn = aws_cloudwatch_log_group.opensearch_audit.arn

  # Optional profiler logs configuration
  profiler_logs_enabled   = var.enable_profiler_logs
  profiler_logs_group_arn = var.enable_profiler_logs ? aws_cloudwatch_log_group.opensearch_profiler[0].arn : null

  # Enable security plugin auditing via OpenSearch API
  enable_security_plugin_auditing     = var.enable_security_plugin_auditing
  master_username                     = var.opensearch_master_username
  master_password                     = var.opensearch_master_password
  
  # Audit configuration - only disabled categories are configurable
  # All other settings (enable_rest, enable_transport, resolve_bulk_requests, etc.) are hardcoded to true
  audit_rest_disabled_categories      = var.audit_rest_disabled_categories
  audit_disabled_transport_categories = var.audit_disabled_transport_categories
}

//////
// Universal Connector Module - Can be disabled with enable_universal_connector = false
//////

locals {
  # Combine log groups based on what's enabled
  log_groups = var.enable_profiler_logs ? "${aws_cloudwatch_log_group.opensearch_audit.name},${aws_cloudwatch_log_group.opensearch_profiler[0].name}" : aws_cloudwatch_log_group.opensearch_audit.name

  opensearch_csv = templatefile("${path.module}/templates/opensearchCloudwatch.tpl", {
    udc_name            = local.udc_name
    credential_name     = var.udc_aws_credential
    aws_region          = var.aws_region
    aws_account_id      = local.aws_account_id
    aws_log_group       = local.log_groups
    start_position      = var.csv_start_position
    interval            = var.csv_interval
    codec_pattern       = var.codec_pattern
    event_filter        = var.csv_event_filter
    description         = "GDP AWS OpenSearch connector for ${var.opensearch_domain_name}"
    cluster_name        = var.opensearch_domain_name
    opensearch_endpoint = data.aws_opensearch_domain.existing.endpoint
    use_aws_bundled_ca  = var.use_aws_bundled_ca
    log_group_prefix    = var.log_group_prefix
    unmask              = var.unmask
  })
}

module "gdp_connect-datasource-to-uc" {
  source         = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count          = var.enable_universal_connector ? 1 : 0 # Skip creation when disabled
  udc_name       = local.udc_name
  udc_csv_parsed = local.opensearch_csv

  # Directory configuration - SFTP support

  # Multipart upload support

  client_id     = var.gdp_client_id
  client_secret = var.gdp_client_secret
  gdp_server    = var.gdp_server
  gdp_port      = var.gdp_port
  gdp_username  = var.gdp_username
  gdp_password  = var.gdp_password
  gdp_mu_host   = var.gdp_mu_host
}