#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing Neptune parameter group
# This prevents errors when the parameter group already exists in AWS

# Use native Terraform data source to get Neptune cluster information
data "aws_neptune_cluster" "existing" {
  cluster_identifier = var.neptune_cluster_identifier
}

locals {
  # Check if parameter group is default (starts with "default.")
  is_default_param_group = can(regex("^default\\.", data.aws_neptune_cluster.existing.cluster_parameter_group))
  should_import = data.aws_neptune_cluster.existing.cluster_parameter_group != null && !local.is_default_param_group
}

# Null resource to perform import if needed (only for custom parameter groups)
resource "null_resource" "import_neptune_parameter_group" {
  count = local.should_import ? 1 : 0

  triggers = {
    parameter_group_name = data.aws_neptune_cluster.existing.cluster_parameter_group
    cluster_id = var.neptune_cluster_identifier
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if resource exists in state
      if ! terraform state show 'aws_neptune_cluster_parameter_group.guardium' >/dev/null 2>&1; then
        echo "Importing Neptune parameter group: ${data.aws_neptune_cluster.existing.cluster_parameter_group}"
        terraform import 'aws_neptune_cluster_parameter_group.guardium' '${data.aws_neptune_cluster.existing.cluster_parameter_group}' || true
      else
        echo "Neptune parameter group already in state, skipping import"
      fi
    EOT
    
    on_failure = continue
  }
}