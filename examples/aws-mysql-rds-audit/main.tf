#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

provider "aws" {
  region = var.aws_region
}

module "datastore-audit_aws-mysql-rds-audit" {
  source = "../../modules/aws-mysql-rds-audit"

  # AWS Configuration
  aws_region                     = var.aws_region

  # MySQL RDS Configuration
  mysql_rds_cluster_identifier   = var.mysql_rds_cluster_identifier
  mysql_major_version            = var.mysql_major_version
  force_failover                 = var.force_failover

  # Audit Configuration
  audit_events                   = var.audit_events
  audit_file_rotations           = var.audit_file_rotations
  audit_file_rotate_size         = var.audit_file_rotate_size
  audit_incl_users               = var.audit_incl_users
  audit_excl_users               = var.audit_excl_users
  audit_query_log_limit          = var.audit_query_log_limit
  log_export_type                = var.log_export_type

  # Guardium Configuration
  udc_name                       = var.udc_name
  udc_aws_credential             = var.udc_aws_credential
  gdp_client_id                  = var.gdp_client_id
  gdp_client_secret              = var.gdp_client_secret
  gdp_server                     = var.gdp_server
  gdp_port                       = var.gdp_port
  gdp_username                   = var.gdp_username
  gdp_password                   = var.gdp_password
  gdp_ssh_username               = var.gdp_ssh_username
  gdp_ssh_privatekeypath         = var.gdp_ssh_privatekeypath
  gdp_mu_host                    = var.gdp_mu_host

  # Universal Connector Configuration
  enable_universal_connector     = var.enable_universal_connector
  csv_start_position             = var.csv_start_position
  csv_interval                   = var.csv_interval
  csv_event_filter               = var.csv_event_filter

  # Tags
  tags                           = var.tags
}
