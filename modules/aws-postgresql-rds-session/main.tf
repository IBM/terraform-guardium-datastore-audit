locals {
  udc_name = format("%s%s-%s", var.aws_region, var.postgres_rds_cluster_identifier, module.aws_configuration.aws_account_id)
  aws_region     = var.aws_region
  aws_account_id = module.aws_configuration.aws_account_id
  log_group = format("/aws/rds/instance/%s/postgresql", var.postgres_rds_cluster_identifier)
}

module "common_aws-configuration" {
  source = "IBM/common/guardium//modules/aws-configuration"
}

data "aws_db_instance" "cluster_metadata" {
    db_instance_identifier = var.postgres_rds_cluster_identifier
}

module "common_rds-postgres-parameter-group" {
  source = "IBM/common/guardium//modules/rds-postgres-parameter-group"
  pg_audit_log = "all, -misc"
  pg_audit_role = ""
  force_failover = var.force_failover
  postgres_rds_cluster_identifier = var.postgres_rds_cluster_identifier
  aws_region = var.aws_region
}

module "common_rds-postgres-sqs-registration" {
  count  = var.log_export_type == "SQS" ? 1 : 0
  source = "IBM/common/guardium//modules/rds-postgres-sqs-registration"

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
}

module "common_rds-postgres-cloudwatch-registration" {
  count  = var.log_export_type == "Cloudwatch" ? 1 : 0
  source = "IBM/common/guardium//modules/rds-postgres-cloudwatch-registration"

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
}
