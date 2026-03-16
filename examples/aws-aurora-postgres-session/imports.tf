#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing parameter groups
# Import blocks must be in the root module, so we place them here in the example

# Get existing cluster parameter group information
data "aws_rds_cluster" "existing" {
  cluster_identifier = var.aurora_postgres_cluster_identifier
}

# Local to determine if we should import (only if it's NOT a default parameter group)
locals {
  is_default_pg = can(regex("^default\\.", data.aws_rds_cluster.existing.db_cluster_parameter_group_name))
  should_import = !local.is_default_pg
  pg_name       = data.aws_rds_cluster.existing.db_cluster_parameter_group_name
}

# Import existing cluster parameter group only if it's not a default one
import {
  for_each = local.should_import ? toset(["import"]) : toset([])
  to       = module.datastore-audit_aws-aurora-postgres-session.module.common_aurora-postgres-parameter-group.aws_rds_cluster_parameter_group.guardium
  id       = local.pg_name
}