locals {
  udc_name = format("%s%s-%s", var.aws_region, var.mariadb_rds_cluster_identifier, local.aws_account_id)
  aws_region     = var.aws_region
  aws_account_id = module.aws_configuration.aws_account_id
  log_group = format("/aws/rds/instance/%s/audit", var.mariadb_rds_cluster_identifier)
}

module "common_aws-configuration" {
  source = "IBM/common/guardium//modules/aws-configuration"
}

module "common_rds-mariadb-parameter-group" {
  source = "IBM/common/guardium//modules/rds-mariadb-parameter-group"

  mariadb_rds_cluster_identifier = var.mariadb_rds_cluster_identifier
  mariadb_major_version = var.mariadb_major_version
  audit_events = var.audit_events
  audit_file_rotations = var.audit_file_rotations
  audit_file_rotate_size = var.audit_file_rotate_size
  force_failover = var.force_failover
  aws_region = var.aws_region
  tags = var.tags
}

module "common_rds-postgres-cloudwatch-registration" {
  count  = var.log_export_type == "Cloudwatch" ? 1 : 0
  source = "IBM/common/guardium//modules/rds-mariadb-cloudwatch-registration"

  aws_region = var.aws_region
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
  mariadb_rds_cluster_identifier = var.mariadb_rds_cluster_identifier
}
