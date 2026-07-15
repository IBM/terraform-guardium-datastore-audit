# Databricks Audit with IBM Guardium Data Protection (UC 2.0 - Unity Catalog)

This example demonstrates how to configure Azure Databricks Unity Catalog workspace audit logging with IBM Guardium Data Protection using the `databricks-audit` module in UC 2.0 mode.

## Architecture

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│                     │     │                     │     │                     │
│  Azure Databricks   │────►│  Azure Monitor      │────►│  Azure Event Hub    │
│  Unity Catalog      │     │  Diagnostic Setting │     │                     │
│  Workspace          │     │  (+ unityCatalog    │     └─────────────────────┘
└─────────────────────┘     │   log category)     │               │
                            └─────────────────────┘               │
                                                                   ▼
                                                    ┌─────────────────────────┐
                                                    │  Guardium Universal     │
                                                    │  Connector              │
                                                    │  (Databricks Unity      │
                                                    │   Catalog over          │
                                                    │   Event Hub)            │
                                                    └─────────────────────────┘
                                                                   │
                                                                   ▼
                                                    ┌─────────────────────────┐
                                                    │  Guardium Data          │
                                                    │  Protection             │
                                                    └─────────────────────────┘
```

## Data Flow

1. Databricks Unity Catalog activity is captured by Azure Monitor audit logging
2. Audit logs (including `unityCatalog` events) are streamed to Azure Event Hub via a Diagnostic Setting
3. Guardium Universal Connector reads from Event Hub
4. Guardium processes and analyzes the Databricks Unity Catalog activity

## Overview

This Terraform configuration:

1. Attaches an Azure Monitor Diagnostic Setting to an existing Databricks workspace to stream all standard audit log categories **plus the `unityCatalog` category** to Event Hub
2. Registers a `Databricks Unity Catalog over Event Hub` Universal Connector profile in Guardium

## Difference from UC 1.0 (`databricks-audit`)

This example sets `uc_version = "uc2"` which:

- Adds the `unityCatalog` log category to the Azure Monitor Diagnostic Setting
- Uses the `Databricks Unity Catalog over Event Hub` profile definition name in Guardium

## Prerequisites

Before using this example, ensure you have:

1. **Azure Resources**:
   - An existing Azure Databricks workspace with Unity Catalog enabled
   - An existing Azure Event Hub namespace and Event Hub
   - An existing Azure Storage Account (for Event Hub checkpointing)

2. **Guardium Data Protection**:
   - A running Guardium Data Protection instance
   - Completed the one-time manual configurations as described in [Preparing Guardium Documentation](https://github.com/IBM/terraform-guardium-gdp/blob/main/docs/preparing-guardium.md):
     - OAuth client registered via `grdapi register_oauth_client`

## Usage

### 1. Create a terraform.tfvars File

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values.

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Import the Existing Diagnostic Setting

The Azure Monitor diagnostic setting already exists and must be imported into Terraform state before applying:

```bash
terraform import \
  'module.datastore-audit_databricks-audit-uc2.azurerm_monitor_diagnostic_setting.databricks_audit' \
  '<databricks_workspace_resource_id>|<diagnostic_setting_name>'
```

For example:

```bash
terraform import \
  'module.datastore-audit_databricks-audit-uc2.azurerm_monitor_diagnostic_setting.databricks_audit' \
  '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Databricks/workspaces/my-workspace|nexus-databricks'
```

### 4. Apply the Configuration

```bash
terraform apply
```

### 4. Verify the Configuration

After successful application:

1. Log in to your Guardium Data Protection web interface
2. Navigate to **Universal Connector** → **Datasource Profile Management**
3. Verify the `Databricks Unity Catalog over Event Hub` profile has been created and is active
4. Confirm the profile is deployed to the expected managed units

## Inputs

See [`variables.tf`](./variables.tf) for the full list. Key variables:

| Name | Description | Required |
|------|-------------|:--------:|
| databricks_workspace_name | Name of the Databricks Unity Catalog workspace | yes |
| databricks_workspace_resource_id | Full Azure resource ID of the workspace | yes |
| eventhub_namespace_name | Event Hub namespace name | yes |
| eventhub_name | Event Hub name | yes |
| storage_account_name | Storage account for checkpointing | yes |
| gdp_server | Guardium Central Manager hostname | yes |
| gdp_username | Guardium username | yes |
| gdp_password | Guardium password | yes |
| gdp_client_id | Guardium OAuth client ID | yes |
| gdp_client_secret | Guardium OAuth client secret | yes |
| gdp_mu_host | Guardium Managed Unit hostnames | yes |

## Outputs

| Name | Description |
|------|-------------|
| profile_csv | Universal Connector profile CSV |
| udc_name | Name of the Universal Connector |
| databricks_workspace_name | Name of the monitored Databricks workspace |
| eventhub_namespace_name | Name of the Event Hub namespace |
| eventhub_name | Name of the Event Hub |
| diagnostic_setting_name | Name of the Azure Monitor diagnostic setting |
| subscription_id | Azure subscription ID |
| uc_version | Databricks UC version in use (uc2) |
