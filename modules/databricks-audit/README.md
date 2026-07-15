# Databricks Audit Configuration

This module configures audit logging for Azure Databricks with IBM Guardium Data Protection. It enables Databricks audit log streaming to Azure Event Hub via Azure Monitor Diagnostic Settings and registers the Universal Connector profile in Guardium.

The module supports both standard workspace auditing (UC 1.0) and Unity Catalog auditing (UC 2.0) through the `uc_version` variable.

## Prerequisites

Before using this module, you need to:

1. Have an existing Azure Databricks workspace
2. Have an existing Azure Event Hub namespace and Event Hub
3. Have an existing Azure Storage Account (for Event Hub checkpointing)
4. Have Guardium Data Protection set up with appropriate credentials

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | ~> 3.0 |
| guardium-data-protection | >= 1.0.0 |

## UC Versions

This module supports two Databricks auditing modes via the `uc_version` variable:

- `uc1` — Standard Databricks workspace auditing. Streams the standard set of workspace audit log categories to Event Hub. Uses the `Databricks over Event Hub` Guardium profile definition.
- `uc2` — Unity Catalog auditing. Includes all UC 1.0 log categories **plus** the `unityCatalog` category. Uses the `Databricks Unity Catalog over Event Hub` Guardium profile definition.

### UC Version Behaviour

| Behaviour | `uc1` | `uc2` |
|-----------|-------|-------|
| Standard log categories (accounts, clusters, jobs, etc.) | ✓ | ✓ |
| `unityCatalog` log category | — | ✓ |
| Guardium profile definition name | `Databricks over Event Hub` | `Databricks Unity Catalog over Event Hub` |

## Usage

### 1. Create a terraform.tfvars File

Copy [`terraform.tfvars.example`](./terraform.tfvars.example) to `terraform.tfvars` and fill in your values.

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Import the Existing Diagnostic Setting

The Azure Monitor diagnostic setting already exists and must be imported into Terraform state before applying. The resource address depends on the module name in your root `main.tf`:

```bash
terraform import \
  'module.<your_module_name>.azurerm_monitor_diagnostic_setting.databricks_audit' \
  '<databricks_workspace_resource_id>|<diagnostic_setting_name>'
```

For example, using the `databricks-audit` example:

```bash
terraform import \
  'module.datastore-audit_databricks-audit.azurerm_monitor_diagnostic_setting.databricks_audit' \
  '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Databricks/workspaces/my-workspace|nexus-databricks'
```

Or using the `databricks-audit-uc2` example:

```bash
terraform import \
  'module.datastore-audit_databricks-audit-uc2.azurerm_monitor_diagnostic_setting.databricks_audit' \
  '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Databricks/workspaces/my-workspace|nexus-databricks'
```

> **Note:** Azure diagnostic setting IDs use a pipe-separated format: `<target_resource_id>|<setting_name>`

### 4. Apply the Configuration

```bash
terraform apply
```

Review the planned changes and type `yes` to apply.

### 4. Verify the Configuration

After successful application:

1. Log in to your Guardium Data Protection web interface
2. Navigate to **Universal Connector** → **Datasource Profile Management**
3. Verify the Databricks profile has been created and is active
4. Navigate to the Managed Unit the UC is deployed on and confirm the STAP status is green/active

## Inputs

### Common Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azure_region | Azure region where resources are deployed | string | `"eastus"` | no |
| resource_group_name | Name of the Azure resource group | string | n/a | yes |
| databricks_workspace_name | Name of the Databricks workspace to be monitored | string | n/a | yes |
| databricks_workspace_resource_id | Full Azure resource ID of the Databricks workspace | string | n/a | yes |
| azure_enrollment_id | Azure Enrollment ID | string | `""` | no |
| uc_version | UC version: `uc1` (standard) or `uc2` (Unity Catalog) | string | `"uc1"` | no |
| tags | Map of tags to apply to resources | map(string) | `{}` | no |

### Event Hub Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| eventhub_namespace_name | Name of the Event Hub namespace | string | n/a | yes |
| eventhub_name | Name of the Event Hub | string | n/a | yes |
| eventhub_authorization_rule_name | Event Hub namespace authorization rule name | string | `"RootManageSharedAccessKey"` | no |
| storage_account_name | Storage account name for Event Hub checkpointing | string | n/a | yes |
| consumer_group | Event Hub consumer group name | string | `"$Default"` | no |
| diagnostic_setting_name | Name of the Azure Monitor diagnostic setting | string | `"databricks-audit-to-eventhub"` | no |
| config_mode | Event Hub input config mode (basic or advanced) | string | `"basic"` | no |
| threads | Number of threads for Event Hub consumer | number | `8` | no |
| decorate_events | Whether to decorate events with Event Hub metadata | bool | `true` | no |

### Guardium Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| gdp_server | Hostname/IP of Guardium Central Manager | string | n/a | yes |
| gdp_port | Port of Guardium Central Manager | string | `"8443"` | no |
| gdp_username | Guardium Web UI username | string | n/a | yes |
| gdp_password | Guardium Web UI password | string | n/a | yes |
| gdp_client_id | Guardium OAuth client ID | string | n/a | yes |
| gdp_client_secret | Guardium OAuth client secret | string | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units | string | n/a | yes |
| enable_universal_connector | Whether to enable the Universal Connector | bool | `true` | no |
| csv_start_position | UC start position (beginning or end) | string | `"end"` | no |
| udc_description | Optional UC profile description override | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| profile_csv | Universal Connector profile CSV |
| udc_name | Name of the Universal Connector |
| databricks_workspace_name | Name of the monitored Databricks workspace |
| eventhub_namespace_name | Name of the Event Hub namespace |
| eventhub_name | Name of the Event Hub |
| storage_account_name | Name of the storage account for checkpointing |
| diagnostic_setting_name | Name of the Azure Monitor diagnostic setting |
| subscription_id | Azure subscription ID |
| uc_version | Databricks UC version in use |
