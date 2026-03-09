#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing parameter groups
# Import blocks must be in the root module, so we place them here in the example

# Get existing parameter group information
data "aws_db_instance" "existing" {
  db_instance_identifier = var.postgres_rds_cluster_identifier
}

# Local to determine if we should import (only if it's NOT a default parameter group)
locals {
  is_default_pg = can(regex("^default\\.", data.aws_db_instance.existing.db_parameter_groups[0]))
  should_import = !local.is_default_pg
  pg_name       = data.aws_db_instance.existing.db_parameter_groups[0]
}

# Import existing parameter group only if it's not a default one
import {
  for_each = local.should_import ? toset(["import"]) : toset([])
  to       = module.datastore-audit_aws-postgresql-rds-session.module.common_rds-postgres-parameter-group.aws_db_parameter_group.guardium
  id       = local.pg_name
}