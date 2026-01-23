#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing Redshift parameter group
# This prevents errors when the parameter group already exists in AWS

# Data source to check if parameter group exists
data "external" "check_redshift_parameter_group" {
  program = ["bash", "-c", <<-EOT
    set -e
    PARAM_GROUP=$(aws redshift describe-clusters \
      --cluster-identifier ${var.redshift_cluster_identifier} \
      --region ${var.aws_region} \
      --query "Clusters[0].ClusterParameterGroups[0].ParameterGroupName" \
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
resource "null_resource" "import_redshift_parameter_group" {
  count = var.create_parameter_group && data.external.check_redshift_parameter_group.result.exists == "true" ? 1 : 0

  triggers = {
    parameter_group_name = data.external.check_redshift_parameter_group.result.name
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if resource exists in state
      if ! terraform state show 'aws_redshift_parameter_group.redshift_logging[0]' >/dev/null 2>&1; then
        echo "Importing Redshift parameter group: ${data.external.check_redshift_parameter_group.result.name}"
        terraform import 'aws_redshift_parameter_group.redshift_logging[0]' '${data.external.check_redshift_parameter_group.result.name}' || true
      else
        echo "Redshift parameter group already in state, skipping import"
      fi
    EOT
    
    on_failure = continue
  }
}