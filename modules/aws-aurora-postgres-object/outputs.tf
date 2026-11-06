#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "reboot_required" {
  description = "Whether manual reboot is required to enable audit logging"
  value       = var.enable_audit_setup ? module.aurora-postgres-parameter-group[0].reboot_required : false
}