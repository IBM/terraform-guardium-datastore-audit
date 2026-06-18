# AWS Aurora MySQL Audit Example

This example demonstrates how to configure Guardium Data Protection to monitor an existing AWS Aurora MySQL cluster via CloudWatch logs.

## Overview

This example:
- Connects to an existing Aurora MySQL cluster
- Registers the cluster with Guardium via Universal Connector
- Monitors audit logs exported to CloudWatch

## Prerequisites

1. **Existing Aurora MySQL Cluster**

2. **AWS Credentials** configured in Guardium Data Protection

3. **Guardium Data Protection** instance with:
   - API access enabled
   - OAuth client registered
   - Managed Units configured

4. **Terraform** >= 1.0.0 installed

## Usage

### 1. Configure Variables

Copy the example configuration:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
# AWS Configuration
aws_region                      = "us-east-1"
aurora_mysql_cluster_identifier = "my-aurora-mysql-cluster"
cloudwatch_logs_exports         = ["audit"]

# Guardium Configuration
udc_aws_credential = "my-aws-credential"
gdp_client_id      = "my-client-id"
gdp_client_secret  = "my-client-secret"
gdp_server         = "guardium.example.com"
gdp_username       = "admin"
gdp_password       = "password"
gdp_mu_host        = "managed-unit-1"
```

### 2. Initialize Terraform

```bash
terraform init
```
## Importing Existing Parameter Groups

If your Aurora MySQL cluster already uses a custom parameter group that you want to manage with Terraform, you can import it into the Terraform state. This prevents Terraform from trying to create a new parameter group and allows you to manage the existing one.

### Steps to Import

1. **Identify the parameter group name** attached to your Aurora MySQL cluster:
   ```bash
   aws rds describe-db-clusters --db-cluster-identifier <cluster-identifier> \
     --query 'DBClusters[0].DBClusterParameterGroup' --output text
   ```

2. **Import the parameter group** into Terraform state:
   ```bash
   terraform import 'module.datastore-audit_aws-aurora-mysql.module.common_aurora-mysql-parameter-group.aws_rds_cluster_parameter_group.aurora_mysql_param_group' <parameter-group-name>
   ```

### 3. Plan Deployment

```bash
terraform plan
```

### 4. Deploy Configuration

```bash
terraform apply
```

## Configuration Options

### CloudWatch Log Types

Configure which log types to monitor:

```hcl
# Monitor only audit logs (recommended)
cloudwatch_logs_exports = ["audit"]
```

### Universal Connector Settings

```hcl
# Start from the end of logs (recommended for existing clusters)
csv_start_position = "end"

# Start from the beginning (for new clusters or full history)
csv_start_position = "beginning"

# Polling interval in seconds
csv_interval = "5"
```

## CloudWatch Log Groups

The module monitors CloudWatch log groups with the following naming pattern:

```
/aws/rds/cluster/<cluster-identifier>/audit
```

## Outputs

After deployment, Terraform provides:

```bash
terraform output
```

Outputs include:
- `udc_name` - Universal connector name
- `log_group` - CloudWatch log group(s) being monitored
- `aws_account_id` - AWS Account ID
- `aws_region` - AWS Region

## Troubleshooting

### Issue: Connector not receiving logs

**Solution**: Verify:
1. Aurora MySQL cluster has `enabled_cloudwatch_logs_exports` configured
2. Parameter groups have audit logging enabled
3. AWS credentials in Guardium have CloudWatch read permissions
4. Log groups exist in CloudWatch

### Issue: Authentication errors

**Solution**: Verify:
1. AWS credential name matches what's configured in Guardium
2. OAuth client credentials are correct
3. Guardium user has appropriate permissions

### Issue: No audit logs generated

**Solution**: Verify Aurora MySQL parameter groups:
```sql
-- Check audit logging status
SHOW VARIABLES LIKE 'server_audit%';

-- Should show:
-- server_audit_logging = ON
-- server_audit_events = CONNECT,QUERY (or your configured events)
```




