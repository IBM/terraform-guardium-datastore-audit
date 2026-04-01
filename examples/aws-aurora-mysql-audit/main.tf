#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

provider "aws" {
  region = var.aws_region
}

module "datastore-audit_aws-aurora-mysql" {
  source = "../../modules/aws-aurora-mysql"

  # AWS Configuration
  aws_region = var.aws_region

  # Aurora MySQL Configuration
  aurora_mysql_cluster_identifier = var.aurora_mysql_cluster_identifier
  force_failover                  = var.force_failover

  # Audit Configuration
  audit_events            = var.audit_events
  audit_incl_users        = var.audit_incl_users
  audit_excl_users        = var.audit_excl_users
  cloudwatch_logs_exports = var.cloudwatch_logs_exports
  log_export_type         = var.log_export_type
  cloudwatch_endpoint     = var.cloudwatch_endpoint
  use_aws_bundled_ca      = var.use_aws_bundled_ca

  # Guardium Configuration
  udc_name           = var.udc_name
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
  csv_event_filter           = var.csv_event_filter
  prefix                     = var.prefix
  unmask                     = var.unmask

  # Tags
  tags = var.tags
}
