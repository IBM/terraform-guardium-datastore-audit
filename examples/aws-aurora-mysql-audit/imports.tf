#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing parameter groups
# Import blocks must be in the root module, so we place them here in the example

# Note: Aurora MySQL uses cluster parameter groups, not instance parameter groups
# The audit module does not modify existing parameter groups, so no imports are needed
# This file is included for consistency with other examples

# If you need to import existing Aurora cluster parameter groups, you can add them here:
# import {
#   to = aws_rds_cluster_parameter_group.existing
#   id = "your-cluster-parameter-group-name"
# }