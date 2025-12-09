# AWS RDS PostgreSQL with Session-Level Auditing

This example demonstrates how to configure AWS RDS PostgreSQL with Guardium Universal Connector using session-level auditing.

## Overview

Session-level auditing in PostgreSQL provides broad coverage of database activity. This example:

1. Configures pgAudit to log all SQL statements (except miscellaneous commands)
2. Sets up either SQS or CloudWatch for log collection
3. Configures Guardium Universal Connector to process these logs

## How It Works

The example uses PostgreSQL's pgAudit extension with session-level auditing mode. In this mode:

- pgAudit is configured to log all SQL statements (except miscellaneous commands)
- All database activity is captured regardless of which user or role performs it
- Logs are sent to either SQS or CloudWatch
- Guardium Universal Connector processes these logs

This approach provides comprehensive coverage of database activity, ensuring that all relevant operations are captured for security and compliance purposes.

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values to match your environment.

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Import the existing parameter group:
   ```
   terraform import 'module.datastore-audit_aws-postgresql-rds-session.module.common_rds-postgres-parameter-group.aws_db_parameter_group.guardium' <parameter group>
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

## Audit Log Configuration

This example configures pgAudit to log the following statement classes:

- READ: SELECT, COPY when the source is a relation or a query
- WRITE: INSERT, UPDATE, DELETE, TRUNCATE, COPY when the destination is a relation
- FUNCTION: Function calls and DO blocks
- ROLE: GRANT, REVOKE, CREATE/ALTER/DROP ROLE
- DDL: All DDL that is not included in the ROLE class
- MISC: Miscellaneous commands, such as DISCARD, FETCH, CHECKPOINT, VACUUM, SET (excluded by default)

The default configuration logs all statement classes except MISC to reduce noise in the audit logs.

## Required Variables

See `terraform.tfvars.example` for a complete list of variables and their descriptions.

## Dependencies

This example depends on:
- AWS RDS PostgreSQL instance with pgAudit extension enabled
- Guardium Data Protection platform
- AWS credentials configured in Guardium

## When to Use Session-Level Auditing

Session-level auditing is ideal when:

- You need comprehensive coverage of all database activity
- You have strict compliance requirements that mandate capturing all SQL statements
- You don't need to focus on specific tables but want to monitor all database operations
- You want a simpler configuration that doesn't require specifying individual tables

## Comparison with Object-Level Auditing

Session-level auditing differs from object-level auditing in the following ways:

1. **Coverage**: Session-level auditing captures all SQL statements regardless of which tables they affect, while object-level auditing focuses only on specific tables.

2. **Configuration**: Session-level auditing is simpler to configure as it doesn't require setting up specific grants for tables.

3. **Log Volume**: Session-level auditing typically generates more logs since it captures all database activity.

4. **Use Case**: Session-level auditing is ideal for comprehensive security monitoring and compliance requirements, while object-level auditing is better for focused monitoring of sensitive tables.
