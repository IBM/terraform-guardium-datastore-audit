#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  udc_name = format("%s%s-%s", var.aws_region, var.mysql_rds_cluster_identifier, local.aws_account_id)
  aws_region     = var.aws_region
  aws_account_id = module.common_aws-configuration.aws_account_id
  log_group_audit = format("/aws/rds/instance/%s/audit", var.mysql_rds_cluster_identifier)
  log_group_error = format("/aws/rds/instance/%s/error", var.mysql_rds_cluster_identifier)
  # Combine log groups based on what's enabled in cloudwatch_logs_exports
  log_group = contains(var.cloudwatch_logs_exports, "error") ? "${local.log_group_audit},${local.log_group_error}" : local.log_group_audit
}

module "common_aws-configuration" {
  source = "IBM/common/guardium//modules/aws-configuration"
}

module "common_rds-mariadb-mysql-parameter-group" {
  source = "IBM/common/guardium//modules/rds-mariadb-mysql-parameter-group"

  db_engine = "mysql"
  rds_cluster_identifier = var.mysql_rds_cluster_identifier
  audit_events = var.audit_events
  audit_file_rotations = var.audit_file_rotations
  audit_file_rotate_size = var.audit_file_rotate_size
  audit_incl_users = var.audit_incl_users
  audit_excl_users = var.audit_excl_users
  audit_query_log_limit = var.audit_query_log_limit
  cloudwatch_logs_exports = var.cloudwatch_logs_exports
  force_failover = var.force_failover
  aws_region = var.aws_region
  tags = var.tags
}

module "common_rds-mariadb-mysql-cloudwatch-registration" {
  count  = var.log_export_type == "Cloudwatch" ? 1 : 0
  source = "IBM/common/guardium//modules/rds-mariadb-mysql-cloudwatch-registration"

  db_engine = "mysql"
  rds_cluster_identifier = var.mysql_rds_cluster_identifier
  aws_region = var.aws_region
  aws_account_id = local.aws_account_id
  gdp_client_id = var.gdp_client_id
  gdp_client_secret = var.gdp_client_secret
  gdp_password = var.gdp_password
  gdp_username = var.gdp_username
  gdp_server = var.gdp_server
  gdp_port = var.gdp_port
  gdp_mu_host = var.gdp_mu_host
  gdp_ssh_privatekeypath = var.gdp_ssh_privatekeypath
  gdp_ssh_username = var.gdp_ssh_username
  udc_name = var.udc_name
  udc_aws_credential = var.udc_aws_credential
  log_group = local.log_group
  enable_universal_connector = var.enable_universal_connector
  csv_start_position = var.csv_start_position
  csv_interval = var.csv_interval
  csv_event_filter = var.csv_event_filter
  codec_pattern = var.codec_pattern
  cloudwatch_endpoint = var.cloudwatch_endpoint
  use_aws_bundled_ca = var.use_aws_bundled_ca
  use_multipart_upload     = var.use_multipart_upload
  profile_upload_directory = var.profile_upload_directory
  profile_api_directory    = var.profile_api_directory
}
