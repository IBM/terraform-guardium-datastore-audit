# AWS Aurora PostgreSQL with Object-Level Auditing

This example demonstrates how to configure AWS Aurora PostgreSQL with Guardium Universal Connector using object-level auditing.

## Overview

Object-level auditing in Aurora PostgreSQL provides granular control over what database operations are audited. This example:

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

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values to match your environment:
   ```
   cp terraform.tfvars.example terraform.tfvars
   ```
   
   **CRITICAL**: You MUST complete this step and fill in ALL required values before proceeding:
   - **`aurora_postgres_cluster_identifier`** - CANNOT be empty! Set this to your actual cluster name
   - **`db_host`**, **`db_username`**, **`db_password`** - Database connection details
   - All Guardium connection details must be filled in
   - Leaving any required variable empty will cause errors during import/plan/apply
   
   To find your cluster identifier:
   ```bash
   aws rds describe-db-clusters --query "DBClusters[*].DBClusterIdentifier" --output text
   ```

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Import the existing cluster parameter group:

   **Find your cluster's parameter group:**
   
   Use the cluster identifier from your `terraform.tfvars` file:
   ```bash
   aws rds describe-db-clusters \
     --db-cluster-identifier <your-cluster-identifier> \
     --query "DBClusters[0].DBClusterParameterGroup" \
     --output text
   ```
   
   **Import the parameter group:**
   ```bash
   terraform import 'module.aurora_postgres_object_audit.module.aurora-postgres-parameter-group.aws_rds_cluster_parameter_group.guardium' <parameter-group-name>
   ```
   
   **Note**: The quotes around the module path are important when the path contains hyphens.

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
- AWS Aurora PostgreSQL cluster with pgAudit extension enabled
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

1. **AWS Region Setting**: You MUST set the `aws_region` variable in your terraform.tfvars file to match the region where your Aurora PostgreSQL cluster is deployed.

2. **Provider Configuration**: This example includes a provider configuration for both the AWS provider and the GDP Middleware Helper provider, ensuring that both use the same region.

3. **Common Issues**: If you encounter region-related issues (e.g., resources being created in us-east-1 despite setting a different region), verify that:
   - Your terraform.tfvars file has the correct `aws_region` value
   - You're not overriding the region with environment variables (e.g., AWS_REGION or AWS_DEFAULT_REGION)
   - You've run `terraform init` after changing regions

## Aurora vs RDS PostgreSQL

Key differences when using Aurora PostgreSQL compared to RDS PostgreSQL:

1. **Cluster Parameter Groups**: Aurora uses cluster parameter groups instead of instance parameter groups
2. **Endpoint**: Aurora provides a cluster endpoint that automatically handles failover
3. **Failover**: Aurora supports automatic failover with the `force_failover` parameter
4. **Performance**: Aurora typically provides better performance and scalability
5. **Storage**: Aurora uses a distributed storage system that automatically scales

## Troubleshooting


### Parameter Group Import Issues

If you encounter errors during the import step:
- Verify the parameter group name is correct
- Ensure you have the necessary AWS permissions
- Check that the parameter group is associated with your Aurora cluster
- **Most importantly**: Ensure `terraform.tfvars` is configured BEFORE running import

### Connection Issues

If Terraform cannot connect to the database:
- Verify the `db_host` is the cluster endpoint (not a reader endpoint)
- Check security group rules allow connections from your Terraform execution environment
- Ensure the database credentials are correct
- Verify SSL mode settings match your Aurora cluster configuration

