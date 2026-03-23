#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

provider "aws" {
  region = var.aws_region
}

module "datastore-audit_amazon-opensearch-audit" {
  source = "../../modules/amazon-opensearch-audit"

  # AWS Configuration
  aws_region             = var.aws_region
  opensearch_domain_name = var.opensearch_domain_name
  enable_profiler_logs   = var.enable_profiler_logs

  # OpenSearch Security Plugin Auditing
  enable_security_plugin_auditing     = var.enable_security_plugin_auditing
  opensearch_master_username          = var.opensearch_master_username
  opensearch_master_password          = var.opensearch_master_password
  audit_rest_disabled_categories      = var.audit_rest_disabled_categories
  audit_disabled_transport_categories = var.audit_disabled_transport_categories

  # Guardium Configuration
  udc_aws_credential = var.udc_aws_credential
  gdp_client_id      = var.gdp_client_id
  gdp_client_secret  = var.gdp_client_secret
  gdp_server         = var.gdp_server
  gdp_port           = var.gdp_port
  gdp_username       = var.gdp_username
  gdp_password       = var.gdp_password
  gdp_mu_host        = var.gdp_mu_host

  # Universal Connector Configuration
  enable_universal_connector = var.enable_universal_connector
  csv_start_position         = var.csv_start_position
  csv_interval               = var.csv_interval
  codec_pattern              = var.codec_pattern
  csv_event_filter           = var.csv_event_filter
  use_aws_bundled_ca         = var.use_aws_bundled_ca
  log_group_prefix           = var.log_group_prefix
  unmask                     = var.unmask

  # Tags
  tags = var.tags
}
