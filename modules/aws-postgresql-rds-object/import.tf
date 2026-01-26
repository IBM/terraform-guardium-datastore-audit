#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing PostgreSQL RDS parameter group
# This prevents errors when the parameter group already exists in AWS

# Use native Terraform data source to get DB instance information
data "aws_db_instance" "existing" {
  db_instance_identifier = var.postgres_rds_cluster_identifier
}

# Null resource to perform import if needed
resource "null_resource" "import_parameter_group" {
  count = length(data.aws_db_instance.existing.db_parameter_groups) > 0 ? 1 : 0

  triggers = {
    parameter_group_name = data.aws_db_instance.existing.db_parameter_groups[0]
    instance_id          = var.postgres_rds_cluster_identifier
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if resource exists in state
      if ! terraform state show 'module.common_rds-postgres-parameter-group.aws_db_parameter_group.db_param_group' >/dev/null 2>&1; then
        echo "Importing PostgreSQL parameter group: ${data.aws_db_instance.existing.db_parameter_groups[0]}"
        terraform import 'module.common_rds-postgres-parameter-group.aws_db_parameter_group.db_param_group' '${data.aws_db_instance.existing.db_parameter_groups[0]}' || true
      else
        echo "PostgreSQL parameter group already in state, skipping import"
      fi
    EOT

    on_failure = continue
  }
}