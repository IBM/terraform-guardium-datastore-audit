#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing parameter groups
# Note: Aurora PostgreSQL parameter group modification is handled by the module via gdp-middleware-helper_aurora_modify
# If you need to import an existing Aurora cluster parameter group into Terraform state manually:
# import {
#   to = module.aurora_postgres_session_audit.module.aurora-postgres-parameter-group.aws_rds_cluster_parameter_group.guardium
#   id = "your-cluster-parameter-group-name"
# }