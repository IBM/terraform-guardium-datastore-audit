provider "aws" {
  region = "us-east-1"
}

module "postgresql_rds_object" {
  source = "../../modules/aws-postgresql-rds-object"

  # Basic configuration
  aws_region                     = var.aws_region
  postgres_rds_cluster_identifier = var.postgres_rds_cluster_identifier
  force_failover                 = var.force_failover
  db_host                        = var.db_host
  db_port                        = var.db_port
  db_username                    = var.db_username
  db_password                    = var.db_password
  db_name                        = var.db_name
  ssl_mode                       = var.ssl_mode

  # Guardium configuration
  udc_name                       = var.udc_name
  udc_aws_credential             = var.udc_aws_credential
  gdp_client_secret              = var.gdp_client_secret
  gdp_client_id                  = var.gdp_client_id
  gdp_server                     = var.gdp_server
  gdp_port                       = var.gdp_port
  gdp_username                   = var.gdp_username
  gdp_password                   = var.gdp_password
  gdp_ssh_username               = var.gdp_ssh_username
  gdp_ssh_privatekeypath         = var.gdp_ssh_privatekeypath
  gdp_mu_host                    = var.gdp_mu_host

  # Universal Connector configuration
  enable_universal_connector     = var.enable_universal_connector
  csv_start_position             = var.csv_start_position
  csv_interval                   = var.csv_interval
  csv_event_filter               = var.csv_event_filter
  log_export_type                = var.log_export_type

  # Table-specific grants configuration
  tables = var.tables
}
