# AWS RDS PostgreSQL with Object-Level Auditing

This example demonstrates how to configure AWS RDS PostgreSQL with Guardium Universal Connector using object-level auditing.

## Overview

Object-level auditing in PostgreSQL provides granular control over what database operations are audited. This example:

1. Creates a dedicated audit role (`rds_pgaudit`)
2. Grants specific permissions to this role for the tables you want to monitor
3. Configures pgAudit to log operations performed by this role
4. Sets up either SQS or CloudWatch for log collection
5. Configures Guardium Universal Connector to process these logs

## How It Works

The example uses PostgreSQL's pgAudit extension with object-level auditing mode. In this mode:

- A dedicated role (`rds_pgaudit`) is created
- This role is granted specific permissions on tables you want to monitor
- When these permissions are used, pgAudit logs the operations
- Logs are sent to either SQS or CloudWatch
- Guardium Universal Connector processes these logs

This approach allows you to focus auditing on specific tables and operations, reducing the volume of audit logs while still capturing critical activity.

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values to match your environment.

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Import the existing parameter group:
   ```
   terraform import 'module.datastore-audit_aws-postgresql-rds-object.module.common_rds-postgres-parameter-group.aws_db_parameter_group.guardium' <parameter group name>
   ```
   
   __NOTE__ To get the parameter group name, you can use the AWS CLI:
   ```
   aws rds describe-db-parameter-groups --query "DBParameterGroups[*].DBParameterGroupName" --output text
   ```
   
   Look for a parameter group with a name pattern like `rds-postgresql-[your-identifier]-guardium-postgresql-params`.
   
   Alternatively, to get both the database identifier and parameter group name in a more readable format, you can use:
   ```
   aws rds describe-db-instances \
     --region <your-aws-region> \
     --filters "Name=dbi-resource-id,Values=<your-db-resource-id>" \
     --query "DBInstances[0].{Identifier:DBInstanceIdentifier, ParameterGroup:DBParameterGroups[0].DBParameterGroupName}"
   ```
   
   Replace:
   - `<your-aws-region>` with your AWS region (e.g., us-west-2, us-east-1)
   - `<your-db-resource-id>` with your database resource ID (e.g., db-TBSNSJGYX4BPL7Y4FJSQULMM44)
   
   You can find your database resource ID in the AWS Console under RDS → Databases → Configuration tab, or by running:
   ```
   aws rds describe-db-instances --query "DBInstances[*].[DBInstanceIdentifier,DbiResourceId]" --output table
   ```

4. Apply the configuration:
   ```
   terraform apply
   ```

## Table Configuration

The `tables` variable allows you to specify which tables to monitor and what operations to audit:

```hcl
tables = [
  {
    schema = "public"    # Schema name
    table  = "users"     # Table name
    grants = ["SELECT", "INSERT", "UPDATE", "DELETE"]  # Operations to audit
  }
]
```

Valid grant options are:
- SELECT
- INSERT
- UPDATE
- DELETE
- REFERENCES
- TRIGGER
- ALL

## Required Variables

See `terraform.tfvars.example` for a complete list of variables and their descriptions.

## Dependencies

This example depends on:
- AWS RDS PostgreSQL instance with pgAudit extension enabled
- Guardium Data Protection platform
- AWS credentials configured in Guardium

## When to Use Object-Level Auditing

Object-level auditing is ideal when:

- You need to focus on specific tables (e.g., those containing sensitive data)
- You want to reduce the volume of audit logs
- You need granular control over which operations are audited
- You have specific compliance requirements for certain tables

## Important Notes on AWS Region Configuration

When deploying this example in a different AWS region:

1. **AWS Region Setting**: You MUST set the `aws_region` variable in your terraform.tfvars file to match the region where your RDS PostgreSQL instance is deployed.

2. **Provider Configuration**: This example includes a provider configuration for both the AWS provider and the GDP Middleware Helper provider, ensuring that both use the same region.

3. **Common Issues**: If you encounter region-related issues (e.g., resources being created in us-east-1 despite setting a different region), verify that:
   - Your terraform.tfvars file has the correct `aws_region` value
   - You're not overriding the region with environment variables (e.g., AWS_REGION or AWS_DEFAULT_REGION)
   - You've run `terraform init` after changing regions