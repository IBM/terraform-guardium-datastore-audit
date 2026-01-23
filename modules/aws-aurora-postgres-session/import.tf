#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing Aurora PostgreSQL cluster parameter group
# This prevents errors when the parameter group already exists in AWS

# Data source to check if cluster parameter group exists
data "external" "check_cluster_parameter_group" {
  program = ["bash", "-c", <<-EOT
    set -e
    PARAM_GROUP=$(aws rds describe-db-clusters \
      --db-cluster-identifier ${var.aurora_postgres_cluster_identifier} \
      --region ${var.aws_region} \
      --query "DBClusters[0].DBClusterParameterGroup" \
      --output text 2>/dev/null || echo "")
    
    if [ -z "$PARAM_GROUP" ] || [ "$PARAM_GROUP" = "None" ]; then
      echo '{"exists":"false","name":""}'
    else
      echo "{\"exists\":\"true\",\"name\":\"$PARAM_GROUP\"}"
    fi
  EOT
  ]
}

# Null resource to perform import if needed
resource "null_resource" "import_cluster_parameter_group" {
  count = data.external.check_cluster_parameter_group.result.exists == "true" ? 1 : 0

  triggers = {
    parameter_group_name = data.external.check_cluster_parameter_group.result.name
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if resource exists in state
      if ! terraform state show 'module.aurora-postgres-parameter-group.aws_rds_cluster_parameter_group.db_cluster_param_group' >/dev/null 2>&1; then
        echo "Importing Aurora PostgreSQL cluster parameter group: ${data.external.check_cluster_parameter_group.result.name}"
        terraform import 'module.aurora-postgres-parameter-group.aws_rds_cluster_parameter_group.db_cluster_param_group' '${data.external.check_cluster_parameter_group.result.name}' || true
      else
        echo "Aurora PostgreSQL cluster parameter group already in state, skipping import"
      fi
    EOT
    
    on_failure = continue
  }
}