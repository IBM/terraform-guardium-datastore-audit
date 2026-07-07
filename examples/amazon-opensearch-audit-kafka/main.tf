#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

provider "aws" {
  region = var.aws_region
}

module "datastore-audit_amazon-opensearch-audit-kafka" {
  source = "../../modules/amazon-opensearch-audit"

  # AWS Configuration
  aws_region             = var.aws_region
  opensearch_domain_name = var.opensearch_domain_name
  enable_profiler_logs   = var.enable_profiler_logs
  uc_mode                = "kafka"

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
  udc_name                   = var.udc_name
  udc_description            = var.udc_description

  # Kafka-specific Configuration
  kafka_cluster_name   = var.kafka_cluster_name
  use_elb              = var.use_elb
  event_delay          = var.event_delay
  nodata_threshold_min = var.nodata_threshold_min
  unmask               = var.unmask
  filter_pattern       = var.filter_pattern
  poll_interval        = var.poll_interval
  event_limit          = var.event_limit
  start_time           = var.start_time

  # Tags
  tags = var.tags
}
