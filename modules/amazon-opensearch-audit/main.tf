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

//////
// CloudWatch Log Groups for OpenSearch Audit and Profiler Logs
//////
resource "aws_cloudwatch_log_group" "audit_log_group" {
  name = "/aws/OpenSearchService/domains/${var.opensearch_domain_name}/audit-logs"
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "profiler_log_group" {
  count = var.enable_profiler_logs ? 1 : 0
  name  = "/aws/OpenSearchService/domains/${var.opensearch_domain_name}/index-slow-logs"
  tags  = var.tags
}

//////
// CloudWatch Log Resource Policy for OpenSearch
//////
data "aws_iam_policy_document" "opensearch_log_policy" {
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

    resources = concat(
      ["${aws_cloudwatch_log_group.audit_log_group.arn}:*"],
      var.enable_profiler_logs ? ["${aws_cloudwatch_log_group.profiler_log_group[0].arn}:*"] : []
    )
  }
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_log_policy" {
  policy_name     = "opensearch-${var.opensearch_domain_name}-log-policy"
  policy_document = data.aws_iam_policy_document.opensearch_log_policy.json
}

//////
// OpenSearch Domain Resource
//
// This resource manages ONLY the log_publishing_options for the domain.
// All other domain settings are ignored to prevent accidental changes.
//////
resource "aws_opensearch_domain" "audit" {
  domain_name = var.opensearch_domain_name

  log_publishing_options {
    log_type                 = "AUDIT_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.audit_log_group.arn
    enabled                  = true
  }

  dynamic "log_publishing_options" {
    for_each = var.enable_profiler_logs ? [1] : []
    content {
      log_type                 = "INDEX_SLOW_LOGS"
      cloudwatch_log_group_arn = aws_cloudwatch_log_group.profiler_log_group[0].arn
      enabled                  = true
    }
  }

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_resource_policy.opensearch_log_policy
  ]

  lifecycle {
    # Prevent accidental domain destruction
    prevent_destroy = true

    # Ignore ALL domain configuration except log_publishing_options and tags
    # This ensures we only manage logging, not the entire domain
    ignore_changes = [
      engine_version,
      cluster_config,
      ebs_options,
      encrypt_at_rest,
      node_to_node_encryption,
      domain_endpoint_options,
      advanced_security_options,
      advanced_options,
      vpc_options,
      snapshot_options,
      cognito_options,
      auto_tune_options,
    ]
  }
}

//////
// Enable OpenSearch Security Plugin Auditing via API
// CloudWatch logging is handled by aws_opensearch_domain resource above
//////
resource "gdp-middleware-helper_opensearch_modify" "enable_security_audit" {
  count                                = var.enable_security_plugin_auditing ? 1 : 0
  domain_name                          = var.opensearch_domain_name
  region                               = var.aws_region
  enable_security_plugin_auditing      = true
  master_username                      = var.opensearch_master_username
  master_password                      = var.opensearch_master_password
  audit_rest_disabled_categories       = var.audit_rest_disabled_categories
  audit_disabled_transport_categories  = var.audit_disabled_transport_categories

  depends_on = [
    aws_opensearch_domain.audit
  ]
}

//////
// Universal Connector Module - Can be disabled with enable_universal_connector = false
//////

locals {
  # Log group names for Universal Connector
  audit_log_group_name    = aws_cloudwatch_log_group.audit_log_group.name
  profiler_log_group_name = var.enable_profiler_logs ? aws_cloudwatch_log_group.profiler_log_group[0].name : ""

  # Combine log groups based on what's enabled
  log_groups = var.enable_profiler_logs ? "${local.audit_log_group_name},${local.profiler_log_group_name}" : local.audit_log_group_name

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
    opensearch_endpoint = aws_opensearch_domain.audit.endpoint
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
  client_id     = var.gdp_client_id
  client_secret = var.gdp_client_secret
  gdp_server    = var.gdp_server
  gdp_port      = var.gdp_port
  gdp_username  = var.gdp_username
  gdp_password  = var.gdp_password
  gdp_mu_host   = var.gdp_mu_host
}
