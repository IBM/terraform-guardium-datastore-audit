#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing parameter groups
# Import blocks must be in the root module, so we place them here in the example

# Get existing parameter group information
data "aws_db_instance" "existing" {
  db_instance_identifier = var.mariadb_rds_cluster_identifier
}

# Locals to determine if we should import
locals {
  is_default_pg    = can(regex("^default\\.", data.aws_db_instance.existing.db_parameter_groups[0]))
  should_import_pg = !local.is_default_pg
  pg_name          = data.aws_db_instance.existing.db_parameter_groups[0]

  has_option_group = length(data.aws_db_instance.existing.option_group_memberships) > 0
  is_default_og    = local.has_option_group ? can(regex("^default:", data.aws_db_instance.existing.option_group_memberships[0])) : true
  should_import_og = local.has_option_group && !local.is_default_og
  og_name          = local.has_option_group ? data.aws_db_instance.existing.option_group_memberships[0] : ""
}

# Import existing parameter group only if it's not a default one
import {
  for_each = local.should_import_pg ? toset(["import"]) : toset([])
  to       = module.datastore-audit_aws-mariadb-rds-audit.module.common_rds-mariadb-mysql-parameter-group.aws_db_parameter_group.db_param_group
  id       = local.pg_name
}

# Import existing option group only if it's not a default one
import {
  for_each = local.should_import_og ? toset(["import"]) : toset([])
  to       = module.datastore-audit_aws-mariadb-rds-audit.module.common_rds-mariadb-mysql-parameter-group.aws_db_option_group.audit
  id       = local.og_name
}