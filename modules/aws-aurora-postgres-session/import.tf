#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing Aurora PostgreSQL cluster parameter group
# This prevents errors when the parameter group already exists in AWS

# Use native Terraform data source to get cluster information
data "aws_rds_cluster" "existing" {
  cluster_identifier = var.aurora_postgres_cluster_identifier
}

# Null resource to perform import if needed
resource "null_resource" "import_cluster_parameter_group" {
  count = data.aws_rds_cluster.existing.db_cluster_parameter_group_name != null ? 1 : 0

  triggers = {
    parameter_group_name = data.aws_rds_cluster.existing.db_cluster_parameter_group_name
    cluster_id           = var.aurora_postgres_cluster_identifier
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if resource exists in state
      if ! terraform state show 'module.aurora-postgres-parameter-group.aws_rds_cluster_parameter_group.db_cluster_param_group' >/dev/null 2>&1; then
        echo "Importing Aurora PostgreSQL cluster parameter group: ${data.aws_rds_cluster.existing.db_cluster_parameter_group_name}"
        terraform import 'module.aurora-postgres-parameter-group.aws_rds_cluster_parameter_group.db_cluster_param_group' '${data.aws_rds_cluster.existing.db_cluster_parameter_group_name}' || true
      else
        echo "Aurora PostgreSQL cluster parameter group already in state, skipping import"
      fi
    EOT

    on_failure = continue
  }
}