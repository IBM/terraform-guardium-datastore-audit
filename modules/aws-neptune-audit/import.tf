#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing Neptune parameter group
# This prevents errors when the parameter group already exists in AWS

# Data source to check if parameter group exists and if it's custom
data "external" "check_neptune_parameter_group" {
  program = ["bash", "-c", <<-EOT
    set -e
    PARAM_GROUP=$(aws neptune describe-db-clusters \
      --db-cluster-identifier ${var.neptune_cluster_identifier} \
      --region ${var.aws_region} \
      --query "DBClusters[0].DBClusterParameterGroup" \
      --output text 2>/dev/null || echo "")
    
    if [ -z "$PARAM_GROUP" ] || [ "$PARAM_GROUP" = "None" ]; then
      echo '{"exists":"false","name":"","is_default":"true"}'
    else
      # Check if it's a default parameter group (starts with "default.")
      if [[ "$PARAM_GROUP" == default.* ]]; then
        echo "{\"exists\":\"true\",\"name\":\"$PARAM_GROUP\",\"is_default\":\"true\"}"
      else
        echo "{\"exists\":\"true\",\"name\":\"$PARAM_GROUP\",\"is_default\":\"false\"}"
      fi
    fi
  EOT
  ]
}

# Null resource to perform import if needed (only for custom parameter groups)
resource "null_resource" "import_neptune_parameter_group" {
  count = data.external.check_neptune_parameter_group.result.exists == "true" && data.external.check_neptune_parameter_group.result.is_default == "false" ? 1 : 0

  triggers = {
    parameter_group_name = data.external.check_neptune_parameter_group.result.name
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if resource exists in state
      if ! terraform state show 'aws_neptune_cluster_parameter_group.guardium' >/dev/null 2>&1; then
        echo "Importing Neptune parameter group: ${data.external.check_neptune_parameter_group.result.name}"
        terraform import 'aws_neptune_cluster_parameter_group.guardium' '${data.external.check_neptune_parameter_group.result.name}' || true
      else
        echo "Neptune parameter group already in state, skipping import"
      fi
    EOT
    
    on_failure = continue
  }
}