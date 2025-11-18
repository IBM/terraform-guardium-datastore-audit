#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  log_group = format("/aws/rds/cluster/%s/postgresql", var.aurora_postgres_cluster_identifier)
}

module "aws_configuration" {
  source = "IBM/terraform-guardium-common//modules/aws-configuration"
}

data "aws_rds_cluster" "cluster_metadata" {
  cluster_identifier = var.aurora_postgres_cluster_identifier
}

module "aurora-postgres-parameter-group" {
  source = "IBM/terraform-guardium-common//modules/aurora-postgres-parameter-group"
  pg_audit_log = var.pg_audit_log
  pg_audit_role = ""  # Not used in session auditing
  force_failover = var.force_failover
  aurora_postgres_cluster_identifier = var.aurora_postgres_cluster_identifier
  aws_region = var.aws_region
}

module "aurora-postgres-sqs-registration" {
  count  = var.log_export_type == "SQS" ? 1 : 0
  source = "IBM/terraform-guardium-common//modules/aurora-postgres-sqs-registration"

  aws_account_id = module.aws_configuration.aws_account_id
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
}

module "aurora-postgres-cloudwatch-registration" {
  count  = var.log_export_type == "Cloudwatch" ? 1 : 0
  source = "IBM/terraform-guardium-common//modules/aurora-postgres-cloudwatch-registration"

  aws_account_id = module.aws_configuration.aws_account_id
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
}