#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing DocumentDB parameter group
# This prevents errors when the parameter group already exists in AWS

# Use external data source with AWS CLI since there's no native Terraform data source for DocumentDB clusters
data "external" "docdb_cluster_info" {
  program = ["bash", "-c", <<-EOT
    set -e
    PARAM_GROUP=$(aws docdb describe-db-clusters \
      --db-cluster-identifier '${var.documentdb_cluster_identifier}' \
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
  existing_parameter_group_name = data.external.docdb_cluster_info.result.parameter_group
  # Check if parameter group is default (starts with "default.")
  is_default_param_group_import = can(regex("^default\\.", local.existing_parameter_group_name))
  should_import_param_group     = local.existing_parameter_group_name != "" && !local.is_default_param_group_import
}

# Null resource to perform import if needed (only for custom parameter groups)
resource "null_resource" "import_docdb_parameter_group" {
  count = local.should_import_param_group ? 1 : 0

  triggers = {
    parameter_group_name = local.existing_parameter_group_name
    cluster_id           = var.documentdb_cluster_identifier
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if resource exists in state
      if ! terraform state show 'aws_docdb_cluster_parameter_group.guardium' >/dev/null 2>&1; then
        echo "Importing DocumentDB parameter group: ${local.existing_parameter_group_name}"
        terraform import 'aws_docdb_cluster_parameter_group.guardium' '${local.existing_parameter_group_name}' || true
      else
        echo "DocumentDB parameter group already in state, skipping import"
      fi
    EOT

    on_failure = continue
  }
}