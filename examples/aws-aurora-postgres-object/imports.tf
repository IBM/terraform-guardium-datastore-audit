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

# Import existing cluster parameter group if it's not a default one
import {
  to = module.datastore-audit_aws-aurora-postgres-object.module.common_aurora-postgres-parameter-group.aws_rds_cluster_parameter_group.guardium
  id = can(regex("^default\\.", data.aws_rds_cluster.existing.db_cluster_parameter_group_name)) ? null : data.aws_rds_cluster.existing.db_cluster_parameter_group_name
}