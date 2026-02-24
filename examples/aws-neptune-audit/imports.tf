#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing parameter groups
# Import blocks must be in the root module, so we place them here in the example

# Use external data source to get Neptune cluster parameter group info
data "external" "neptune_cluster_info" {
  program = ["bash", "-c", <<-EOT
    set -e
    PARAM_GROUP=$(aws neptune describe-db-clusters \
      --db-cluster-identifier '${var.neptune_cluster_identifier}' \
      --region '${var.aws_region}' \
      --query 'DBClusters[0].DBClusterParameterGroup' \
      --output text 2>/dev/null || echo "")
    
    if [ -z "$PARAM_GROUP" ] || [ "$PARAM_GROUP" = "None" ]; then
      echo '{"parameter_group":""}'
    else
      echo "{\"parameter_group\":\"$PARAM_GROUP\"}"
    fi
  EOT
  ]
}

locals {
  existing_parameter_group_name = data.external.neptune_cluster_info.result.parameter_group
  # Check if parameter group is default (starts with "default.")
  is_default_param_group = can(regex("^default\\.", local.existing_parameter_group_name))
  should_import_param_group = local.existing_parameter_group_name != "" && !local.is_default_param_group
}

# Import existing Neptune parameter group only if it's not a default one
import {
  for_each = local.should_import_param_group ? toset(["import"]) : toset([])
  to = module.datastore-audit_aws-neptune-audit.aws_neptune_cluster_parameter_group.guardium
  id = local.existing_parameter_group_name
}