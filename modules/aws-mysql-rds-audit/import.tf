#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing parameter group and option group
# This prevents errors when the parameter group already exists in AWS

# Data source to check if parameter group exists
data "external" "check_parameter_group" {
  program = ["bash", "-c", <<-EOT
    set -e
    PARAM_GROUP=$(aws rds describe-db-instances \
      --db-instance-identifier ${var.mysql_rds_cluster_identifier} \
      --region ${var.aws_region} \
      --query "DBInstances[0].DBParameterGroups[0].DBParameterGroupName" \
      --output text 2>/dev/null || echo "")
    
    if [ -z "$PARAM_GROUP" ] || [ "$PARAM_GROUP" = "None" ]; then
      echo '{"exists":"false","name":""}'
    else
      echo "{\"exists\":\"true\",\"name\":\"$PARAM_GROUP\"}"
    fi
  EOT
  ]
}

# Data source to check if option group exists
data "external" "check_option_group" {
  program = ["bash", "-c", <<-EOT
    set -e
    OPTION_GROUP=$(aws rds describe-db-instances \
      --db-instance-identifier ${var.mysql_rds_cluster_identifier} \
      --region ${var.aws_region} \
      --query "DBInstances[0].OptionGroupMemberships[0].OptionGroupName" \
      --output text 2>/dev/null || echo "")
    
    if [ -z "$OPTION_GROUP" ] || [ "$OPTION_GROUP" = "None" ]; then
      echo '{"exists":"false","name":""}'
    else
      echo "{\"exists\":\"true\",\"name\":\"$OPTION_GROUP\"}"
    fi
  EOT
  ]
}

# Null resource to perform import if needed
resource "null_resource" "import_parameter_group" {
  count = data.external.check_parameter_group.result.exists == "true" ? 1 : 0

  triggers = {
    parameter_group_name = data.external.check_parameter_group.result.name
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if resource exists in state
      if ! terraform state show 'module.common_rds-mariadb-mysql-parameter-group.aws_db_parameter_group.db_param_group' >/dev/null 2>&1; then
        echo "Importing parameter group: ${data.external.check_parameter_group.result.name}"
        terraform import 'module.common_rds-mariadb-mysql-parameter-group.aws_db_parameter_group.db_param_group' '${data.external.check_parameter_group.result.name}' || true
      else
        echo "Parameter group already in state, skipping import"
      fi
    EOT
    
    on_failure = continue
  }
}

# Null resource to perform option group import if needed
resource "null_resource" "import_option_group" {
  count = data.external.check_option_group.result.exists == "true" ? 1 : 0

  triggers = {
    option_group_name = data.external.check_option_group.result.name
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if resource exists in state
      if ! terraform state show 'module.common_rds-mariadb-mysql-parameter-group.aws_db_option_group.audit' >/dev/null 2>&1; then
        echo "Importing option group: ${data.external.check_option_group.result.name}"
        terraform import 'module.common_rds-mariadb-mysql-parameter-group.aws_db_option_group.audit' '${data.external.check_option_group.result.name}' || true
      else
        echo "Option group already in state, skipping import"
      fi
    EOT
    
    on_failure = continue
  }
}