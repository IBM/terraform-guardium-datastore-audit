#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing Redshift parameter group
# This prevents errors when the parameter group already exists in AWS

# Use native Terraform data source to get Redshift cluster information
data "aws_redshift_cluster" "existing" {
  cluster_identifier = var.redshift_cluster_identifier
}

# Null resource to perform import if needed
resource "null_resource" "import_redshift_parameter_group" {
  count = var.create_parameter_group && data.aws_redshift_cluster.existing.cluster_parameter_group_name != null ? 1 : 0

  triggers = {
    parameter_group_name = data.aws_redshift_cluster.existing.cluster_parameter_group_name
    cluster_id           = var.redshift_cluster_identifier
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if resource exists in state
      if ! terraform state show 'aws_redshift_parameter_group.redshift_logging[0]' >/dev/null 2>&1; then
        echo "Importing Redshift parameter group: ${data.aws_redshift_cluster.existing.cluster_parameter_group_name}"
        terraform import 'aws_redshift_parameter_group.redshift_logging[0]' '${data.aws_redshift_cluster.existing.cluster_parameter_group_name}' || true
      else
        echo "Redshift parameter group already in state, skipping import"
      fi
    EOT

    on_failure = continue
  }
}