#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  udc_name = format("%s%s-%s", var.aws_region, var.neptune_cluster_identifier, local.aws_account_id)
  aws_partition  = data.aws_partition.current.partition
  aws_region     = data.aws_region.current.id
  aws_account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

# aws does not expose a get of family_name easily which is required for below parameter group modification
# this is a part of our internal provider to supply this
data "gdp-middleware-helper_neptune_parameter_group" "cluster_metadata" {
  cluster_identifier = var.neptune_cluster_identifier
  region = var.aws_region
}

# we will only need to create a new parameter group here if it is not the default parameter group
# if its not the default, proceed with what was discovered in the previous step
locals {
  default_pg_name = format("default.%s", data.gdp-middleware-helper_neptune_parameter_group.cluster_metadata.family_name)
  is_default_pg   = contains(
    [data.gdp-middleware-helper_neptune_parameter_group.cluster_metadata.parameter_group],
    local.default_pg_name
  )
  parameter_group_name = local.is_default_pg ? format("guardium-neptune-param-group-%s", var.neptune_cluster_identifier) : data.gdp-middleware-helper_neptune_parameter_group.cluster_metadata.parameter_group
  description = local.is_default_pg ? format("Custom parameter group for enabling audit for %s", var.neptune_cluster_identifier) : data.gdp-middleware-helper_neptune_parameter_group.cluster_metadata.description
}


resource "aws_neptune_cluster_parameter_group" "guardium" {
  name        = local.parameter_group_name
  description = local.description
  family = data.gdp-middleware-helper_neptune_parameter_group.cluster_metadata.family_name

  parameter {
    name  = "neptune_enable_audit_log"
    value = "1"
    apply_method = "pending-reboot"
  }

  tags = var.tags
}

# Use the GDP middleware helper to modify the Neptune cluster and enable audit log exports
resource "gdp-middleware-helper_neptune_modify" "enable_audit_logs" {
  depends_on = [
    aws_neptune_cluster_parameter_group.guardium,
  ]

  cluster_identifier              = var.neptune_cluster_identifier
  region                          = var.aws_region
  cluster_parameter_group_name    = aws_neptune_cluster_parameter_group.guardium.name
  cloudwatch_logs_exports         = ["audit"]
  apply_immediately               = true
}

# Reboot Neptune cluster instances to apply the parameter group changes
# Neptune requires a reboot for neptune_enable_audit_log parameter to take effect
resource "gdp-middleware-helper_neptune_reboot" "reboot_cluster" {
  depends_on = [
    gdp-middleware-helper_neptune_modify.enable_audit_logs,
  ]

  cluster_identifier = var.neptune_cluster_identifier
  region             = var.aws_region
}

//////
// Universal Connector Module - Can be disabled with enable_universal_connector = false
//////

locals {
  neptune_csv = templatefile("${path.module}/templates/neptuneCloudwatch.tpl", {
    udc_name        = local.udc_name
    credential_name = var.udc_aws_credential
    aws_region      = var.aws_region
    aws_account_id  = local.aws_account_id
    # the aws log group here gets automatically created for us when we enable auditing on the neptune cluster
    #   /aws/neptune/<cluster-name>/audit
    aws_log_group = format("/aws/neptune/%s/audit", var.neptune_cluster_identifier)
    start_position  = var.csv_start_position
    interval        = var.csv_interval
    codec_pattern   = var.codec_pattern
    event_filter    = var.csv_event_filter
    description     = "GDP AWS Neptune connector for ${var.neptune_cluster_identifier}"
    cluster_name    = var.neptune_cluster_identifier
    neptune_endpoint = var.neptune_endpoint
    use_aws_bundled_ca = var.use_aws_bundled_ca
  })
}

module "gdp_connect-datasource-to-uc" {
  source = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count  = var.enable_universal_connector ? 1 : 0  # Skip creation when disabled
  udc_name = local.udc_name
  udc_csv_parsed = local.neptune_csv
  
  # Directory configuration - SFTP support
  
  # Multipart upload support
  
  client_id              = var.gdp_client_id
  client_secret          = var.gdp_client_secret
  gdp_server             = var.gdp_server
  gdp_port               = var.gdp_port
  gdp_username           = var.gdp_username
  gdp_password           = var.gdp_password
  gdp_mu_host            = var.gdp_mu_host
}
