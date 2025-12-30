locals {
  udc_name       = format("%s%s-%s", var.aws_region, var.documentdb_cluster_identifier, local.aws_account_id)
  aws_partition  = data.aws_partition.current.partition
  aws_region     = data.aws_region.current.name
  aws_account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

# aws does not expose a get of family_name easily which is required for below parameter group modification
# this is a part of our internal provider to supply this
data "gdp-middleware-helper_docdb_parameter_group" "cluster_metadata" {
  cluster_identifier = var.documentdb_cluster_identifier
  region             = var.aws_region
}

# we will only need to create a new parameter group here if it is not the default parameter group
# if its not the default, proceed with what was discovered in the previous step
locals {
  default_pg_name = format("default.%s", data.gdp-middleware-helper_docdb_parameter_group.cluster_metadata.family_name)
  is_default_pg = contains(
    [data.gdp-middleware-helper_docdb_parameter_group.cluster_metadata.parameter_group],
    local.default_pg_name
  )
  parameter_group_name = local.is_default_pg ? format("guardium-docdb-param-group-%s", var.documentdb_cluster_identifier) : data.gdp-middleware-helper_docdb_parameter_group.cluster_metadata.parameter_group
  description          = local.is_default_pg ? format("Custom parameter group for enabling about for %s", var.documentdb_cluster_identifier) : data.gdp-middleware-helper_docdb_parameter_group.cluster_metadata.description
}


resource "aws_docdb_cluster_parameter_group" "guardium" {
  name        = local.parameter_group_name
  description = local.description
  family      = data.gdp-middleware-helper_docdb_parameter_group.cluster_metadata.family_name

  parameter {
    name         = "audit_logs"
    value        = "enabled"
    apply_method = "immediate"
  }

  parameter {
    name         = "profiler"
    value        = "enabled"
    apply_method = "immediate"
  }

  parameter {
    name         = "profiler_threshold_ms"
    value        = "50"
    apply_method = "immediate"
  }

  tags = var.tags
}

//////
// Universal Connector Module - Can be disabled with enable_universal_connector = false
//////

locals {
  document_db_csv = templatefile("${path.module}/templates/documentdbCloudwatch.tpl", {
    udc_name        = local.udc_name
    credential_name = var.udc_aws_credential
    aws_region      = var.aws_region
    aws_account_id  = local.aws_account_id
    # the aws log group here gets automatically created for us when we enable auditing on the document db
    #   /aws/docdb/guardium-docdb/audit
    # Using only audit log group to avoid comma-separated values issue
    aws_log_group   = format("/aws/docdb/%s/audit", var.documentdb_cluster_identifier)
    start_position  = var.csv_start_position
    interval        = var.csv_interval
    event_filter    = var.csv_event_filter
    description     = "GDP AWS DocumentDB connector for ${var.documentdb_cluster_identifier}"
    codec_pattern       = var.codec_pattern
    cloudwatch_endpoint = var.cloudwatch_endpoint
    use_aws_bundled_ca  = var.use_aws_bundled_ca
    cluster_name    = var.documentdb_cluster_identifier
  })
}
module "gdp_connect-datasource-to-uc" {
  source         = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count          = var.enable_universal_connector ? 1 : 0 # Skip creation when disabled
  udc_name       = local.udc_name
  udc_csv_parsed = local.document_db_csv

  # Directory configuration - pass through to child module

  client_id              = var.gdp_client_id
  client_secret          = var.gdp_client_secret
  gdp_server             = var.gdp_server
  gdp_port               = var.gdp_port
  gdp_username           = var.gdp_username
  gdp_password           = var.gdp_password
  gdp_mu_host            = var.gdp_mu_host
}

output "profile_csv" {
  value = var.enable_universal_connector ? module.gdp_connect-datasource-to-uc[0].profile_csv : "Universal connector disabled"
}
