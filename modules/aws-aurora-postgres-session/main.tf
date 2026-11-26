#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  # If user provides udc_name, use it exactly. Otherwise auto-generate from region, cluster and account.
  udc_name       = var.udc_name != "" ? var.udc_name : format("%s-%s-%s", var.aws_region, var.aurora_postgres_cluster_identifier, local.aws_account_id)
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
  version = "= 1.7.5"
}

data "aws_rds_cluster" "cluster_metadata" {
  cluster_identifier = var.aurora_postgres_cluster_identifier
}

# Preserve existing state for users who applied before enable_audit_setup was introduced
moved {
  from = module.aurora-postgres-parameter-group
  to   = module.aurora-postgres-parameter-group[0]
}

module "aurora-postgres-parameter-group" {
  count                              = var.enable_audit_setup ? 1 : 0
  source                             = "IBM/common/guardium//modules/aurora-postgres-parameter-group"
  version                            = "= 1.7.5"
  pg_audit_log                       = var.pg_audit_log
  pg_audit_role                      = "" # Not used in session auditing
  force_failover                     = var.force_failover
  skip_reboot                        = var.skip_reboot
  cloudwatch_logs_exports            = var.cloudwatch_logs_exports
  aurora_postgres_cluster_identifier = var.aurora_postgres_cluster_identifier
  aws_region                         = var.aws_region
}

module "aurora-postgres-sqs-registration" {
  count   = var.uc_mode != "kafka" && var.log_export_type == "SQS" ? 1 : 0
  source  = "IBM/common/guardium//modules/aurora-postgres-sqs-registration"
  version = "= 1.7.5"

  udc_name                           = local.udc_name
  aws_account_id                     = module.aws_configuration.aws_account_id
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
  version = "= 1.7.5"

  udc_name                           = local.udc_name
  aws_region                         = var.aws_region
  aws_account_id                     = module.aws_configuration.aws_account_id
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

# Kafka registration. Provider resources are used directly because the registry module
# connect-datasource-to-uc installs the profile even when its connection test fails.

moved {
  from = module.aurora-postgres-kafka-registration[0].local_file.csv_temp
  to   = local_file.kafka_csv_temp[0]
}

moved {
  from = module.aurora-postgres-kafka-registration[0].guardium-data-protection_import_profiles.import_profiles
  to   = guardium-data-protection_import_profiles.kafka_import_profiles[0]
}

moved {
  from = module.aurora-postgres-kafka-registration[0].guardium-data-protection_install_connector.install_connector
  to   = guardium-data-protection_install_connector.kafka_install_connector[0]
}

resource "local_file" "kafka_csv_temp" {
  count    = var.uc_mode == "kafka" && var.enable_universal_connector ? 1 : 0
  content  = local.aurora_postgres_kafka_csv
  filename = "${path.root}/.terraform/${local.udc_name}.csv"
}

data "guardium-data-protection_authentication" "kafka_access_token" {
  count         = var.uc_mode == "kafka" && var.enable_universal_connector ? 1 : 0
  client_secret = var.gdp_client_secret
  username      = var.gdp_username
  password      = var.gdp_password
  client_id     = var.gdp_client_id
}

resource "guardium-data-protection_import_profiles" "kafka_import_profiles" {
  count            = var.uc_mode == "kafka" && var.enable_universal_connector ? 1 : 0
  access_token     = data.guardium-data-protection_authentication.kafka_access_token[0].access_token
  path_to_file     = abspath(local_file.kafka_csv_temp[0].filename)
  update_mode      = true
  test_connections = true
}

resource "guardium-data-protection_install_connector" "kafka_install_connector" {
  count         = var.uc_mode == "kafka" && var.enable_universal_connector ? 1 : 0
  access_token  = data.guardium-data-protection_authentication.kafka_access_token[0].access_token
  udc_name      = local.udc_name
  gdp_mu_host   = var.gdp_mu_host
  skip_profiles = guardium-data-protection_import_profiles.kafka_import_profiles[0].failed_connection_test_profiles

  lifecycle {
    ignore_changes = [access_token] # token rotation would otherwise trigger an Update that drops the resource id
  }
}
