provider "aws" {
  region = "us-east-1"
}

module "datastore-audit_aws-postgresql-rds-object" {
  source = "../../modules/aws-postgresql-rds-object"

  # Basic configuration
  aws_region                     = "us-east-1"
  postgres_rds_cluster_identifier = "example-postgres"
  db_host                        = "example-postgres.abcdefg.us-east-1.rds.amazonaws.com"
  db_port                        = 5432
  db_username                    = "admin"
  db_password                    = "example-password"
  db_name                        = "postgres"

  # Guardium configuration
  udc_aws_credential = "aws-credential-name"
  gdp_client_secret  = "client-secret"
  gdp_client_id      = "client-id"
  gdp_server         = "guardium-server.example.com"
  gdp_username       = "guardium-user"
  gdp_password       = "guardium-password"
  gdp_ssh_username   = "guardium-ssh-user"
  gdp_ssh_privatekeypath = "/path/to/private/key"

  # Audit configuration
  auditing_type = "object"

  # Table-specific grants configuration
  tables = [
    {
      schema = "public"
      table  = "users"
      grants = ["SELECT", "INSERT", "UPDATE"]
    },
    {
      schema = "app_schema"
      table  = "transactions"
      grants = ["SELECT"]
    },
    {
      schema = "app_schema"
      table  = "audit_logs"
      grants = ["SELECT", "INSERT"]
    }
  ]
}
