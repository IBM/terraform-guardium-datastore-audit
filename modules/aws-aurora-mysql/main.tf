
#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  udc_name       = format("%s%s-%s", var.aws_region, var.aurora_mysql_cluster_identifier, local.aws_account_id)
  aws_region     = var.aws_region
  aws_account_id = module.common_aws-configuration.aws_account_id
  log_group      = format("/aws/rds/cluster/%s/audit", var.aurora_mysql_cluster_identifier)
  
  # Create a sanitized version of the UDC name for file paths
  udc_name_safe = trimspace(replace(local.udc_name, "/", "-"))
}

module "common_aws-configuration" {
  source = "IBM/common/guardium//modules/aws-configuration"
}

module "common_aurora-mysql-parameter-group" {
  source = "IBM/common/guardium//modules/aurora-mysql-parameter-group"

  aurora_mysql_cluster_identifier = var.aurora_mysql_cluster_identifier
  audit_events                    = var.audit_events
  audit_incl_users                = var.audit_incl_users
  audit_excl_users                = var.audit_excl_users
  cloudwatch_logs_exports         = var.cloudwatch_logs_exports
  force_failover                  = var.force_failover
  aws_region                      = var.aws_region
  tags                            = var.tags
}

//////
// Universal Connector Module - Can be disabled with enable_universal_connector = false
//////

locals {
  aurora_mysql_csv = templatefile("${path.module}/templates/auroraMySqlCloudwatch.tpl", {
    udc_name            = local.udc_name_safe
    credential_name     = var.udc_aws_credential
    aws_region          = var.aws_region
    aws_log_group       = local.log_group
    aws_account_id      = local.aws_account_id
    prefix              = var.prefix
    unmask              = var.unmask
    start_position      = var.csv_start_position
    interval            = var.csv_interval
    event_filter        = var.csv_event_filter
    description         = "GDP AWS Aurora MySQL connector for ${var.udc_name}"
    cloudwatch_endpoint = var.cloudwatch_endpoint
    use_aws_bundled_ca  = var.use_aws_bundled_ca
  })
}

module "gdp_connect-datasource-to-uc" {
  source         = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count          = var.enable_universal_connector && var.log_export_type == "Cloudwatch" ? 1 : 0
  udc_name       = local.udc_name_safe
  udc_csv_parsed = local.aurora_mysql_csv

  client_id     = var.gdp_client_id
  client_secret = var.gdp_client_secret
  gdp_server    = var.gdp_server
  gdp_port      = var.gdp_port
  gdp_username  = var.gdp_username
  gdp_password  = var.gdp_password
  gdp_mu_host   = var.gdp_mu_host
}
