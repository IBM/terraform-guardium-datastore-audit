#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  udc_name = format("%s%s-%s", var.aws_region, var.aurora_postgres_cluster_identifier, local.aws_account_id)
  aws_region     = var.aws_region
  aws_account_id = module.aws_configuration.aws_account_id
  log_group = format("/aws/rds/cluster/%s/postgresql", var.aurora_postgres_cluster_identifier)
}

module "aws_configuration" {
  source = "IBM/common/guardium//modules/aws-configuration"
}

locals {
  pg_audit_user = "rds_pgaudit"
}

module "aurora-postgres-parameter-group" {
  source = "IBM/common/guardium//modules/aurora-postgres-parameter-group"
  pg_audit_log = "none"  # For object auditing, we don't use session logging
  pg_audit_role = "rds_pgaudit"  # Use the dedicated audit role
  force_failover = var.force_failover
  aurora_postgres_cluster_identifier = var.aurora_postgres_cluster_identifier
  aws_region = var.aws_region
}

data "gdp-middleware-helper_postgres_role_check" "aurora_pgaudit_exists" {
  db_name = var.db_name
  host = var.db_host
  port = var.db_port
  username = var.db_username
  password = var.db_password
  role_name = local.pg_audit_user
  ssl_mode = var.ssl_mode
}

resource "postgresql_role" "aurora_pgaudit" {
  count  = data.gdp-middleware-helper_postgres_role_check.aurora_pgaudit_exists.exists ? 0 : 1
  name  = local.pg_audit_user
  login = false
}
  
# Grant permissions on tables based on the tables variable
# This resource creates grants for the pgaudit role on specified tables
resource "postgresql_grant" "table_permissions" {
  for_each = { for idx, table in var.tables : "${table.schema}.${table.table}" => table }
  
  database    = var.db_name
  role        = local.pg_audit_user
  schema      = each.value.schema
  object_type = "table"
  objects     = [each.value.table]
  privileges  = each.value.grants
  
  depends_on = [postgresql_role.aurora_pgaudit]
}

module "aurora-postgres-sqs-registration" {
  count  = var.log_export_type == "SQS" ? 1 : 0
  source = "IBM/common/guardium//modules/aurora-postgres-sqs-registration"

  aws_account_id = local.aws_account_id
  gdp_client_id = var.gdp_client_id
  gdp_client_secret = var.gdp_client_secret
  gdp_password = var.gdp_password
  gdp_username = var.gdp_username
  gdp_server = var.gdp_server
  gdp_mu_host = var.gdp_mu_host
  gdp_ssh_privatekeypath = var.gdp_ssh_privatekeypath
  gdp_ssh_username = var.gdp_ssh_username
  udc_aws_credential = var.udc_aws_credential
  log_group = local.log_group
  aurora_postgres_cluster_identifier = var.aurora_postgres_cluster_identifier
  enable_universal_connector = var.enable_universal_connector
  csv_start_position = var.csv_start_position
  csv_interval = var.csv_interval
  csv_event_filter = var.csv_event_filter
  profile_upload_directory = var.profile_upload_directory
  profile_api_directory    = var.profile_api_directory
  use_multipart_upload     = var.use_multipart_upload
}

module "aurora-postgres-cloudwatch-registration" {
  count  = var.log_export_type == "Cloudwatch" ? 1 : 0
  source = "IBM/common/guardium//modules/aurora-postgres-cloudwatch-registration"

  aws_account_id = local.aws_account_id
  gdp_client_id = var.gdp_client_id
  gdp_client_secret = var.gdp_client_secret
  gdp_password = var.gdp_password
  gdp_username = var.gdp_username
  gdp_server = var.gdp_server
  gdp_mu_host = var.gdp_mu_host
  gdp_ssh_privatekeypath = var.gdp_ssh_privatekeypath
  gdp_ssh_username = var.gdp_ssh_username
  udc_aws_credential = var.udc_aws_credential
  log_group = local.log_group
  aurora_postgres_cluster_identifier = var.aurora_postgres_cluster_identifier
  enable_universal_connector = var.enable_universal_connector
  csv_start_position = var.csv_start_position
  csv_interval = var.csv_interval
  csv_event_filter = var.csv_event_filter
  profile_upload_directory = var.profile_upload_directory
  profile_api_directory    = var.profile_api_directory
  use_multipart_upload     = var.use_multipart_upload
  cloudwatch_endpoint      = var.cloudwatch_endpoint
  codec_pattern            = var.codec_pattern
  use_aws_bundled_ca       = var.use_aws_bundled_ca
}