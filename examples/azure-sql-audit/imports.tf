#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic import of existing Azure resources
# Import blocks must be in the root module, so we place them here in the example

# If you have existing audit policies that you want to import:
# import {
#   to = module.datastore-audit_azure-sql-audit.module.common_azure-sql-audit-settings.azurerm_mssql_server_extended_auditing_policy.server_audit[0]
#   id = "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Sql/servers/{server-name}/extendedAuditingSettings/default"
# }

# import {
#   to = module.datastore-audit_azure-sql-audit.module.common_azure-sql-audit-settings.azurerm_mssql_database_extended_auditing_policy.database_audit[0]
#   id = "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Sql/servers/{server-name}/databases/{database-name}/extendedAuditingSettings/default"
# }

# Example:
# import {
#   to = module.datastore-audit_azure-sql-audit.module.common_azure-sql-audit-settings.azurerm_mssql_server_extended_auditing_policy.server_audit[0]
#   id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-guardium-sql/providers/Microsoft.Sql/servers/sql-guardium-test/extendedAuditingSettings/default"
# }

# import {
#   to = module.datastore-audit_azure-sql-audit.module.common_azure-sql-audit-settings.azurerm_mssql_database_extended_auditing_policy.database_audit[0]
#   id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-guardium-sql/providers/Microsoft.Sql/servers/sql-guardium-test/databases/testdb/extendedAuditingSettings/default"
# }