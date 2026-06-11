#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing Azure resources
# Import blocks must be in the root module, so we place them here in the example

# If you have an existing diagnostic setting that you want to import:
# import {
#   to = module.datastore-audit_azure-cosmos-audit.module.common_azure-cosmos-diagnostic-settings.azurerm_monitor_diagnostic_setting.cosmos_audit
#   id = "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.DocumentDB/databaseAccounts/{cosmos-account}/providers/Microsoft.Insights/diagnosticSettings/{diagnostic-setting-name}"
# }

# Example:
# import {
#   to = module.datastore-audit_azure-cosmos-audit.module.common_azure-cosmos-diagnostic-settings.azurerm_monitor_diagnostic_setting.cosmos_audit
#   id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-guardium-cosmos/providers/Microsoft.DocumentDB/databaseAccounts/cosmos-guardium-test/providers/Microsoft.Insights/diagnosticSettings/cosmos-guardium-test-diagnostic"
# }