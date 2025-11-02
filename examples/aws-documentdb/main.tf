module "datastore-audit_aws-documentdb" {
  source = "../../modules/aws-documentdb"

  documentdb_cluster_identifier = var.documentdb_cluster_identifier
  gdp_client_id                 = var.gdp_client_id
  gdp_client_secret             = var.gdp_client_secret
  gdp_password                  = var.gdp_password
  gdp_server                    = var.gdp_server
  gdp_ssh_privatekeypath        = var.gdp_ssh_privatekeypath
  gdp_ssh_username              = var.gdp_ssh_username
  gdp_username                  = var.gdp_username
  udc_aws_credential            = var.udc_aws_credential
  gdp_mu_host = var.gdp_mu_host
  tags = var.tags
  aws_region = var.aws_region
  csv_interval = var.csv_interval
}
