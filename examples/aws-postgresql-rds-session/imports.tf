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

# Import existing parameter group if it's not a default one
import {
  to = module.datastore-audit_aws-postgresql-rds-session.module.common_rds-postgres-parameter-group.aws_db_parameter_group.guardium
  id = can(regex("^default\\.", data.aws_db_instance.existing.db_parameter_groups[0])) ? null : data.aws_db_instance.existing.db_parameter_groups[0]
}