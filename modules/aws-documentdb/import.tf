#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing DocumentDB parameter group
# This prevents errors when the parameter group already exists in AWS

# Use native Terraform data source to get DocumentDB cluster information
data "aws_docdb_cluster" "existing" {
  cluster_identifier = var.documentdb_cluster_identifier
}

locals {
  # Check if parameter group is default (starts with "default.")
  is_default_param_group = can(regex("^default\\.", data.aws_docdb_cluster.existing.db_cluster_parameter_group_name))
  should_import = data.aws_docdb_cluster.existing.db_cluster_parameter_group_name != null && !local.is_default_param_group
}

# Null resource to perform import if needed (only for custom parameter groups)
resource "null_resource" "import_docdb_parameter_group" {
  count = local.should_import ? 1 : 0

  triggers = {
    parameter_group_name = data.aws_docdb_cluster.existing.db_cluster_parameter_group_name
    cluster_id = var.documentdb_cluster_identifier
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if resource exists in state
      if ! terraform state show 'aws_docdb_cluster_parameter_group.guardium' >/dev/null 2>&1; then
        echo "Importing DocumentDB parameter group: ${data.aws_docdb_cluster.existing.db_cluster_parameter_group_name}"
        terraform import 'aws_docdb_cluster_parameter_group.guardium' '${data.aws_docdb_cluster.existing.db_cluster_parameter_group_name}' || true
      else
        echo "DocumentDB parameter group already in state, skipping import"
      fi
    EOT
    
    on_failure = continue
  }
}