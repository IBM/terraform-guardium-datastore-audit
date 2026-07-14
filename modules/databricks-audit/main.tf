#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

locals {
  udc_name        = format("%s-databricks-%s", var.databricks_workspace_name, local.subscription_id)
  subscription_id = data.azurerm_client_config.current.subscription_id

  # Default description
  default_description = var.udc_description != "" ? var.udc_description : "GDP Databricks ${var.uc_version == "uc2" ? "Unity Catalog (UC 2.0)" : "UC 1.0"} connector for ${var.databricks_workspace_name}"
}

data "azurerm_client_config" "current" {}

# Get hub-level authorization rule for building the UC connection string
data "azurerm_eventhub_authorization_rule" "eventhub_auth" {
  name                = var.eventhub_authorization_rule_name
  namespace_name      = var.eventhub_namespace_name
  eventhub_name       = var.eventhub_name
  resource_group_name = var.resource_group_name
}

# Get namespace-level authorization rule for the diagnostic setting (requires namespace rule ID)
data "azurerm_eventhub_namespace_authorization_rule" "namespace_auth" {
  name                = var.eventhub_namespace_authorization_rule_name
  namespace_name      = var.eventhub_namespace_name
  resource_group_name = var.resource_group_name
}

# Get Storage Account details for checkpointing connection string
data "azurerm_storage_account" "checkpoint" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Configure Azure Monitor diagnostic settings to stream Databricks audit logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "databricks_audit" {
  name                           = var.diagnostic_setting_name
  target_resource_id             = var.databricks_workspace_resource_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = data.azurerm_eventhub_namespace_authorization_rule.namespace_auth.id

  # Standard audit log categories (both UC 1.0 and UC 2.0)
  enabled_log { category = "accounts" }
  enabled_log { category = "clusters" }
  enabled_log { category = "dbfs" }
  enabled_log { category = "instancePools" }
  enabled_log { category = "jobs" }
  enabled_log { category = "notebook" }
  enabled_log { category = "secrets" }
  enabled_log { category = "sqlPermissions" }
  enabled_log { category = "ssh" }
  enabled_log { category = "workspace" }

  # Unity Catalog additional log category (UC 2.0 only)
  dynamic "enabled_log" {
    for_each = var.uc_version == "uc2" ? [1] : []
    content {
      category = "unityCatalog"
    }
  }
}

//////
// Universal Connector Module - Can be disabled with enable_universal_connector = false
//////

locals {
  # Build Event Hub connection string
  event_hub_connection = format(
    "Endpoint=sb://%s.servicebus.windows.net/;SharedAccessKeyName=%s;SharedAccessKey=%s;EntityPath=%s",
    var.eventhub_namespace_name,
    var.eventhub_authorization_rule_name,
    data.azurerm_eventhub_authorization_rule.eventhub_auth.primary_key,
    var.eventhub_name
  )

  # Build Storage connection string
  storage_connection = format(
    "DefaultEndpointsProtocol=https;AccountName=%s;AccountKey=%s;EndpointSuffix=core.windows.net",
    var.storage_account_name,
    data.azurerm_storage_account.checkpoint.primary_access_key
  )
}

module "common_databricks-eventhub-registration" {
  source = "../../../terraform-guardium-common/modules/databricks-eventhub-registration"

  # Profile Configuration
  uc_version               = var.uc_version
  udc_name                 = var.databricks_workspace_name
  description              = local.default_description
  udc_credential           = var.udc_credential
  cluster_name             = var.gdp_cluster_name
  mu_count                 = var.mu_count
  use_elb                  = var.use_elb
  eventhub_partition_count = var.eventhub_partition_count
  start_time               = var.start_time
  nodata_threshold_min     = var.nodata_threshold_min

  # Azure Configuration
  azure_region          = var.azure_region
  azure_subscription_id = local.subscription_id
  azure_enrollment_id   = var.azure_enrollment_id

  # Event Hub Configuration
  event_hub_connections = local.event_hub_connection
  storage_connection    = local.storage_connection
  consumer_group        = var.consumer_group
  config_mode           = var.config_mode
  threads               = var.threads
  decorate_events       = var.decorate_events

  # Guardium Configuration
  gdp_client_id              = var.gdp_client_id
  gdp_client_secret          = var.gdp_client_secret
  gdp_server                 = var.gdp_server
  gdp_port                   = var.gdp_port
  gdp_username               = var.gdp_username
  gdp_password               = var.gdp_password
  gdp_mu_host                = var.gdp_mu_host
  enable_universal_connector = var.enable_universal_connector
  csv_start_position         = var.csv_start_position

  depends_on = [azurerm_monitor_diagnostic_setting.databricks_audit]
}
