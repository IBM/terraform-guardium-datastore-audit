# AWS Aurora PostgreSQL with Session-Level Auditing

This example demonstrates how to configure AWS Aurora PostgreSQL with Guardium Universal Connector using session-level auditing.

## Overview

Session-level auditing in Aurora PostgreSQL provides comprehensive monitoring of all database activity. This example:

1. Configures pgAudit to log all SQL statements at the session level
2. Sets up either SQS or CloudWatch for log collection
3. Configures Guardium Universal Connector to process these logs

## How It Works

The example uses PostgreSQL's pgAudit extension with session-level auditing mode. In this mode:

- pgAudit is configured to log all SQL statements (except miscellaneous commands by default)
- All database activity is captured regardless of which tables or operations are involved
- Logs are sent to either SQS or CloudWatch
- Guardium Universal Connector processes these logs

This approach provides comprehensive coverage of database activity but may generate a larger volume of audit logs compared to object-level auditing.

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values to match your environment:
   ```
   cp terraform.tfvars.example terraform.tfvars
   ```
   
   **Important**: You MUST complete this step and fill in all required values before proceeding to the next steps, as Terraform needs these variables for the import operation.

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
   terraform import module.aurora_postgres_session_audit.module.aurora-postgres-parameter-group.aws_rds_cluster_parameter_group.guardium <parameter-group-name>
   ```
   
   

4. Apply the configuration:
   ```
   terraform apply
   ```

## pgAudit Log Configuration

The `pg_audit_log` variable controls what types of statements are logged. The default value is `"all, -misc"`, which logs:

- READ: SELECT and COPY when the source is a relation or a query
- WRITE: INSERT, UPDATE, DELETE, TRUNCATE, and COPY when the destination is a relation
- FUNCTION: Function calls and DO blocks
- ROLE: Statements related to roles and privileges (GRANT, REVOKE, CREATE/ALTER/DROP ROLE)
- DDL: All DDL that is not included in the ROLE class
- MISC: Miscellaneous commands (excluded by default)

You can customize this by modifying the `pg_audit_log` variable in your `terraform.tfvars` file. For example:
- `"all"` - Log everything including miscellaneous commands
- `"read, write"` - Log only read and write operations
- `"ddl, role"` - Log only DDL and role management statements

## Required Variables

See `terraform.tfvars.example` for a complete list of variables and their descriptions.

## Dependencies

This example depends on:
- AWS Aurora PostgreSQL cluster with pgAudit extension enabled
- Guardium Data Protection platform
- AWS credentials configured in Guardium

## When to Use Session-Level Auditing

Session-level auditing is ideal when:

- You need comprehensive coverage of all database activity
- You want a simpler configuration without specifying individual tables
- Compliance requirements mandate logging all database operations
- You have sufficient storage and processing capacity for larger log volumes

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

## Session-Level vs Object-Level Auditing

| Feature | Session-Level | Object-Level |
|---------|--------------|--------------|
| Coverage | All database activity | Specific tables only |
| Configuration | Simpler | More complex |
| Log Volume | Higher | Lower |
| Granularity | All operations | Selected operations |
| Use Case | Comprehensive auditing | Targeted auditing |

Choose session-level auditing when you need complete visibility into all database operations. Choose object-level auditing when you want to focus on specific tables and reduce log volume.

## Troubleshooting

### Parameter Group Import Issues

If you encounter errors during the import step:
- Verify the parameter group name is correct
- Ensure you have the necessary AWS permissions
- Check that the parameter group is associated with your Aurora cluster

### High Log Volume

If you're experiencing high log volumes:
- Consider switching to object-level auditing for specific tables
- Adjust the `pg_audit_log` parameter to exclude certain statement types
- Increase the `csv_interval` to reduce polling frequency
- Use event filters with the `csv_event_filter` variable

### Connection Issues

If Terraform cannot connect to the database:
- Verify the `db_host` is the cluster endpoint (not a reader endpoint)
- Check security group rules allow connections from your Terraform execution environment
- Ensure the database credentials are correct
- Verify SSL mode settings match your Aurora cluster configuration