#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  # If user provides udc_name, use it exactly. Otherwise auto-generate from region, cluster and account.
  udc_name       = var.udc_name != "" ? var.udc_name : format("%s-%s-%s", var.aws_region, var.aurora_postgres_cluster_identifier, local.aws_account_id)
  aws_region     = var.aws_region
  aws_account_id = module.aws_configuration.aws_account_id
  log_group      = format("/aws/rds/cluster/%s/postgresql", var.aurora_postgres_cluster_identifier)

  default_description = var.udc_description != "" ? var.udc_description : "GDP AWS Aurora PostgreSQL ${var.uc_mode} connector for ${var.aurora_postgres_cluster_identifier}"

  aurora_postgres_kafka_csv = templatefile("${path.module}/templates/auroraPostgresKafka.tpl", {
    udc_name              = local.udc_name
    description           = local.default_description
    credential_name       = var.udc_aws_credential
    cluster_name          = var.kafka_cluster_name
    use_elb               = var.use_elb
    aws_region            = var.aws_region
    aws_log_group         = local.log_group
    aws_account_id        = local.aws_account_id
    database_cluster_name = var.aurora_postgres_cluster_identifier
    event_delay           = var.event_delay
    nodata_threshold_min  = var.nodata_threshold_min
    unmask                = var.unmask
    filter_pattern        = var.filter_pattern
    poll_interval_sec     = var.poll_interval_sec
    poll_interval         = var.poll_interval
    event_limit           = var.event_limit
    timestamp_start       = var.timestamp_start
  })
}

module "aws_configuration" {
  source  = "IBM/common/guardium//modules/aws-configuration"
  version = "= 1.6.6"
}

locals {
  pg_audit_user = "rds_pgaudit"
}

module "aurora-postgres-parameter-group" {
  count                              = var.enable_audit_setup ? 1 : 0
  source                             = "IBM/common/guardium//modules/aurora-postgres-parameter-group"
  version                            = "= 1.6.6"
  pg_audit_log                       = "none"        # For object auditing, we don't use session logging
  pg_audit_role                      = "rds_pgaudit" # Use the dedicated audit role
  force_failover                     = var.force_failover
  skip_reboot                        = var.skip_reboot
  aurora_postgres_cluster_identifier = var.aurora_postgres_cluster_identifier
  aws_region                         = var.aws_region
}

data "gdp-middleware-helper_postgres_role_check" "aurora_pgaudit_exists" {
  count     = var.enable_audit_setup ? 1 : 0
  db_name   = var.db_name
  host      = var.db_host
  port      = var.db_port
  username  = var.db_username
  password  = var.db_password
  role_name = local.pg_audit_user
  ssl_mode  = var.ssl_mode
}

resource "postgresql_role" "aurora_pgaudit" {
  count = var.enable_audit_setup && !try(data.gdp-middleware-helper_postgres_role_check.aurora_pgaudit_exists[0].exists, false) ? 1 : 0
  name  = local.pg_audit_user
  login = false

  # Wait for the parameter group change and cluster reboot before touching the database
  depends_on = [module.aurora-postgres-parameter-group]
}

# Grant permissions on tables based on the tables variable
# This resource creates grants for the pgaudit role on specified tables
resource "postgresql_grant" "table_permissions" {
  for_each = var.enable_audit_setup ? { for idx, table in var.tables : "${table.schema}.${table.table}" => table } : {}

  database    = var.db_name
  role        = local.pg_audit_user
  schema      = each.value.schema
  object_type = "table"
  objects     = [each.value.table]
  privileges  = each.value.grants

  # Also depend on the parameter group module so grants run after the reboot even when the role already exists
  depends_on = [postgresql_role.aurora_pgaudit, module.aurora-postgres-parameter-group]
}

module "aurora-postgres-sqs-registration" {
  count   = var.uc_mode != "kafka" && var.log_export_type == "SQS" ? 1 : 0
  source  = "IBM/common/guardium//modules/aurora-postgres-sqs-registration"
  version = "= 1.6.6"

  udc_name                           = local.udc_name
  aws_account_id                     = local.aws_account_id
  gdp_client_id                      = var.gdp_client_id
  gdp_client_secret                  = var.gdp_client_secret
  gdp_password                       = var.gdp_password
  gdp_username                       = var.gdp_username
  gdp_server                         = var.gdp_server
  gdp_mu_host                        = var.gdp_mu_host
  udc_aws_credential                 = var.udc_aws_credential
  log_group                          = local.log_group
  aurora_postgres_cluster_identifier = var.aurora_postgres_cluster_identifier
  enable_universal_connector         = var.enable_universal_connector
  csv_start_position                 = var.csv_start_position
  csv_interval                       = var.csv_interval
  csv_event_filter                   = var.csv_event_filter
}

module "aurora-postgres-cloudwatch-registration" {
  count   = var.uc_mode != "kafka" && var.log_export_type == "Cloudwatch" ? 1 : 0
  source  = "IBM/common/guardium//modules/aurora-postgres-cloudwatch-registration"
  version = "= 1.6.6"

  udc_name                           = local.udc_name
  aws_region                         = var.aws_region
  aws_account_id                     = local.aws_account_id
  gdp_client_id                      = var.gdp_client_id
  gdp_client_secret                  = var.gdp_client_secret
  gdp_password                       = var.gdp_password
  gdp_username                       = var.gdp_username
  gdp_server                         = var.gdp_server
  gdp_mu_host                        = var.gdp_mu_host
  udc_aws_credential                 = var.udc_aws_credential
  log_group                          = local.log_group
  aurora_postgres_cluster_identifier = var.aurora_postgres_cluster_identifier
  enable_universal_connector         = var.enable_universal_connector
  csv_start_position                 = var.csv_start_position
  csv_interval                       = var.csv_interval
  csv_event_filter                   = var.csv_event_filter
  cloudwatch_endpoint                = var.cloudwatch_endpoint
  codec_pattern                      = var.codec_pattern
  use_aws_bundled_ca                 = var.use_aws_bundled_ca
}

module "aurora-postgres-kafka-registration" {
  count            = var.uc_mode == "kafka" && var.enable_universal_connector ? 1 : 0
  source           = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  version          = "= 1.3.4"
  udc_name         = local.udc_name
  udc_csv_parsed   = local.aurora_postgres_kafka_csv
  client_id        = var.gdp_client_id
  client_secret    = var.gdp_client_secret
  gdp_server       = var.gdp_server
  gdp_port         = var.gdp_port
  gdp_username     = var.gdp_username
  gdp_password     = var.gdp_password
  gdp_mu_host      = var.gdp_mu_host
  test_connections = true
}
