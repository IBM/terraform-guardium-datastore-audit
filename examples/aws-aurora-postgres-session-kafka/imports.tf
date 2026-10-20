#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing parameter groups
# Import blocks must be in the root module, so we place them here in the example

# Get existing cluster parameter group information
# Only needed when audit setup is enabled
data "aws_rds_cluster" "existing" {
  count              = var.enable_audit_setup ? 1 : 0
  cluster_identifier = var.aurora_postgres_cluster_identifier
}

# Local to determine if we should import (only if audit setup is enabled and it's NOT a default parameter group)
locals {
  is_default_pg = var.enable_audit_setup ? can(regex("^default\\.", data.aws_rds_cluster.existing[0].db_cluster_parameter_group_name)) : true
  should_import = var.enable_audit_setup && !local.is_default_pg
  pg_name       = var.enable_audit_setup ? data.aws_rds_cluster.existing[0].db_cluster_parameter_group_name : ""
}

# Import existing cluster parameter group only if audit setup is enabled and it's not a default one
import {
  for_each = local.should_import ? toset(["import"]) : toset([])
  to       = module.aurora_postgres_session_audit_kafka.module.aurora-postgres-parameter-group[0].aws_rds_cluster_parameter_group.guardium
  id       = local.pg_name
}
