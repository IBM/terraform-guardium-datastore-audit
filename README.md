# Guardium Datastore Audit Configuration Terraform Module

Terraform module which configures AWS datastores for audit logging and integrates them with IBM Guardium Data Protection via Universal Connector.

## Scope

This module automates the configuration of audit logging for various AWS datastores (DynamoDB, DocumentDB, MariaDB RDS, PostgreSQL RDS) and establishes integration with IBM Guardium Data Protection for comprehensive database activity monitoring, security analysis, and compliance reporting.

## High-Level Architecture

The following diagram illustrates how this module orchestrates the configuration of AWS datastores and their integration with Guardium Data Protection:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│                    Guardium Datastore Audit Configuration Module                │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ Orchestrates
                                        ▼
        ┌───────────────────────────────────────────────────────────┐
        │                                                           │
        │              AWS Datastore Configuration                  │
        │                                                           │
        │  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐   │
        │  │  DynamoDB   │  │  DocumentDB  │  │  MariaDB RDS    │   │
        │  │ + CloudTrail│  │  + Audit Logs│  │  + Audit Plugin │   │
        │  └─────────────┘  └──────────────┘  └─────────────────┘   │
        │                                                           │
        │  ┌─────────────────┐  ┌────────────────────────────┐      │
        │  │  MySQL RDS      │  │  PostgreSQL RDS            │      │
        │  │  + Audit Plugin │  │  + pgAudit (Object/Session)│      │
        │  └─────────────────┘  └────────────────────────────┘      │
        │                                                           │
        │  ┌──────────────────────────────────────────────────┐     │
        │  │  Redshift                                        │     │
        │  │  + Connection & User Activity Logs               │     │
        │  └──────────────────────────────────────────────────┘     │
        │                                                           │
        └───────────────────────────────────────────────────────────┘
                                        │
                                        │ Audit Logs
                                        ▼
        ┌───────────────────────────────────────────────────────────┐
        │                                                           │
        │              AWS Log Aggregation Layer                    │
        │                                                           │
        │  ┌─────────────────┐         ┌──────────────────────┐     │
        │  │  CloudWatch     │         │  S3 Buckets          │     │
        │  │  Log Groups     │         │  (CloudTrail Logs)   │     │
        │  └─────────────────┘         └──────────────────────┘     │
        │                                                           │
        └───────────────────────────────────────────────────────────┘
                                        │
                                        │ Log Streaming
                                        ▼
        ┌───────────────────────────────────────────────────────────┐
        │                                                           │
        │         Guardium Universal Connector (UC)                 │
        │                                                           │
        │  • Reads logs from CloudWatch/S3                          │
        │  • Parses and normalizes audit data                       │
        │  • Applies security policies                              │
        │  • Forwards to Guardium Data Protection                   │
        │                                                           │
        └───────────────────────────────────────────────────────────┘
                                        │
                                        │ Processed Audit Data
                                        ▼
        ┌───────────────────────────────────────────────────────────┐
        │                                                           │
        │         Guardium Data Protection (GDP)                    │
        │                                                           │
        │  • Security monitoring and threat detection               │
        │  • Compliance reporting and auditing                      │
        │  • Policy enforcement and alerting                        │
        │  • Activity analysis and forensics                        │
        │                                                           │
        └───────────────────────────────────────────────────────────┘
```

### Architecture Flow

1. **Datastore Configuration**: The module configures each AWS datastore to enable audit logging:
  - **DynamoDB**: Enables CloudTrail data events to capture API calls
  - **DocumentDB**: Enables audit and profiler logs via parameter groups
  - **MariaDB RDS**: Enables MariaDB Audit Plugin via option groups
  - **MySQL RDS**: Enables MariaDB Audit Plugin via option groups (compatible with MySQL)
  - **PostgreSQL RDS**: Configures pgAudit extension for object or session-level auditing
  - **Redshift**: Enables connection and user activity logging to CloudWatch or S3

2. **Log Aggregation**: Audit logs are collected in AWS:
  - CloudWatch Log Groups store structured logs
  - S3 buckets provide long-term storage for CloudTrail logs
  - IAM roles and policies ensure secure access

3. **Universal Connector**: The module deploys and configures Guardium Universal Connector:
  - Establishes connection to CloudWatch Logs or S3
  - Uses AWS credentials configured in Guardium
  - Applies parsing rules specific to each datastore type
  - Streams processed data to Guardium Data Protection

4. **Guardium Integration**: Audit data flows into Guardium for:
  - Real-time security monitoring
  - Compliance reporting (PCI-DSS, HIPAA, GDPR, etc.)
  - Threat detection and alerting
  - Forensic analysis and investigation

## Supported Datastores

This module provides audit configuration for the following AWS datastores:

| Datastore | Module Path | Audit Method | Log Destination |
|-----------|-------------|--------------|-----------------|
| AWS DynamoDB | `modules/aws-dynamodb` | CloudTrail Data Events | CloudWatch Logs |
| AWS DocumentDB | `modules/aws-documentdb` | DocumentDB Audit Logs | CloudWatch Logs |
| AWS MariaDB RDS | `modules/aws-mariadb-rds-audit` | MariaDB Audit Plugin | CloudWatch Logs |
| AWS MySQL RDS | `modules/aws-mysql-rds-audit` | MariaDB Audit Plugin | CloudWatch Logs |
| AWS PostgreSQL RDS (Object) | `modules/aws-postgresql-rds-object` | pgAudit (Object-Level) | CloudWatch/SQS |
| AWS PostgreSQL RDS (Session) | `modules/aws-postgresql-rds-session` | pgAudit (Session-Level) | CloudWatch/SQS |
| AWS Redshift | `modules/aws-redshift` | Connection & User Activity Logs | CloudWatch Logs/S3 |

## Prerequisites

Before using this module, ensure you have:

1. **AWS Account**: With appropriate permissions to create and manage:
  - CloudTrail and CloudWatch resources
  - IAM roles and policies
  - S3 buckets
  - Database parameter/option groups
  - SQS queues (for PostgreSQL modules)

2. **Guardium Data Protection Instance**: A running GDP cluster with:
  - SSH access configured
  - Web UI credentials with appropriate permissions
  - OAuth client registered via `grdapi register_oauth_client`
  - AWS credentials configured in Universal Connector

3. **Terraform**: Version 1.0.0 or later

4. **AWS CLI**: Configured with appropriate credentials

## Usage

### AWS DynamoDB Audit Configuration

Monitor DynamoDB tables with comprehensive API call tracking:

```hcl
module "dynamodb_audit" {
  source = "IBM/datastore-audit/guardium//modules/aws-dynamodb"

  # AWS Configuration
  aws_region      = "us-east-1"
  dynamodb_tables = "users-table,orders-table"  # or "all" for all tables
  name_prefix     = "my-dynamodb-audit"

  # Guardium Configuration
  gdp_server             = "guardium.example.com"
  gdp_port               = "8443"
  gdp_username           = "admin"
  gdp_password           = "password"
  gdp_ssh_username       = "root"
  gdp_ssh_privatekeypath = "~/.ssh/guardium_key"
  gdp_client_id          = "client1"
  gdp_client_secret      = "client-secret"
  
  # Universal Connector Configuration
  udc_aws_credential = "aws-credential-name"
  gdp_mu_host        = "guardium-mu.example.com"

  tags = {
    Environment = "production"
    Project     = "data-security"
  }
}
```

### AWS DocumentDB Audit Configuration

Enable comprehensive audit logging for DocumentDB clusters:

```hcl
module "documentdb_audit" {
  source = "IBM/datastore-audit/guardium//modules/aws-documentdb"

  # AWS Configuration
  aws_region                    = "us-east-1"
  documentdb_cluster_identifier = "my-docdb-cluster"
  
  # Guardium Configuration
  gdp_server             = "guardium.example.com"
  gdp_port               = "8443"
  gdp_username           = "admin"
  gdp_password           = "password"
  gdp_ssh_username       = "root"
  gdp_ssh_privatekeypath = "~/.ssh/guardium_key"
  gdp_client_id          = "client1"
  gdp_client_secret      = "client-secret"
  
  # Universal Connector Configuration
  udc_name           = "docdb-connector"
  udc_aws_credential = "aws-credential-name"
  gdp_mu_host        = "guardium-mu.example.com"

  tags = {
    Environment = "production"
  }
}
```

### AWS MariaDB RDS Audit Configuration

Configure MariaDB Audit Plugin for RDS instances:

```hcl
module "mariadb_audit" {
  source = "IBM/datastore-audit/guardium//modules/aws-mariadb-rds-audit"

  # AWS Configuration
  aws_region                     = "us-east-1"
  mariadb_rds_cluster_identifier = "my-mariadb-instance"
  mariadb_major_version          = "10.6"
  
  # Audit Configuration
  audit_events          = "CONNECT,QUERY"
  
  # Guardium Configuration
  gdp_server             = "guardium.example.com"
  gdp_username           = "admin"
  gdp_password           = "password"
  gdp_ssh_username       = "root"
  gdp_ssh_privatekeypath = "~/.ssh/guardium_key"
  gdp_client_id          = "client1"
  gdp_client_secret      = "client-secret"
  
  # Universal Connector Configuration
  udc_aws_credential = "aws-credential-name"
  log_export_type    = "Cloudwatch"

  tags = {
    Environment = "production"
  }
}
```

### AWS MySQL RDS Audit Configuration

Configure MariaDB Audit Plugin for MySQL RDS instances:

```hcl
module "mysql_audit" {
  source = "IBM/datastore-audit/guardium//modules/aws-mysql-rds-audit"

  # AWS Configuration
  aws_region                   = "us-east-1"
  mysql_rds_cluster_identifier = "my-mysql-instance"
  mysql_major_version          = "5.7"
  
  # Audit Configuration
  audit_events          = "CONNECT,QUERY"
  
  # Guardium Configuration
  gdp_server             = "guardium.example.com"
  gdp_username           = "admin"
  gdp_password           = "password"
  gdp_ssh_username       = "root"
  gdp_ssh_privatekeypath = "~/.ssh/guardium_key"
  gdp_client_id          = "client1"
  gdp_client_secret      = "client-secret"
  
  # Universal Connector Configuration
  udc_aws_credential = "aws-credential-name"
  log_export_type    = "Cloudwatch"

  tags = {
    Environment = "production"
  }
}
```

### AWS PostgreSQL RDS Object-Level Audit Configuration

Monitor specific tables with granular control:

```hcl
module "postgres_object_audit" {
  source = "IBM/datastore-audit/guardium//modules/aws-postgresql-rds-object"

  # AWS Configuration
  aws_region                      = "us-east-1"
  postgres_rds_cluster_identifier = "my-postgres-db"
  
  # Database Connection
  db_host     = "my-postgres-db.example.region.rds.amazonaws.com"
  db_port     = 5432
  db_username = "admin"
  db_password = "password"
  db_name     = "postgres"
  
  # Tables to Monitor
  tables = [
    {
      schema = "public"
      table  = "users"
      grants = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    },
    {
      schema = "public"
      table  = "orders"
      grants = ["SELECT", "INSERT"]
    }
  ]
  
  # Guardium Configuration
  gdp_server             = "guardium.example.com"
  gdp_username           = "admin"
  gdp_password           = "password"
  gdp_ssh_username       = "root"
  gdp_ssh_privatekeypath = "~/.ssh/guardium_key"
  gdp_client_id          = "client1"
  gdp_client_secret      = "client-secret"
  
  # Universal Connector Configuration
  udc_aws_credential = "aws-credential-name"
  log_export_type    = "Cloudwatch"
}
```

### AWS PostgreSQL RDS Session-Level Audit Configuration

Capture all database activity comprehensively:

```hcl
module "postgres_session_audit" {
  source = "IBM/datastore-audit/guardium//modules/aws-postgresql-rds-session"

  # AWS Configuration
  aws_region                      = "us-east-1"
  postgres_rds_cluster_identifier = "my-postgres-db"
  
  # Guardium Configuration
  gdp_server             = "guardium.example.com"
  gdp_username           = "admin"
  gdp_password           = "password"
  gdp_ssh_username       = "root"
  gdp_ssh_privatekeypath = "~/.ssh/guardium_key"
  gdp_client_id          = "client1"
  gdp_client_secret      = "client-secret"
  
  # Universal Connector Configuration
  udc_aws_credential = "aws-credential-name"
  log_export_type    = "Cloudwatch"
}
```

### AWS Redshift Audit Configuration

Enable comprehensive audit logging for Redshift clusters:

```hcl
module "redshift_audit" {
  source = "IBM/datastore-audit/guardium//modules/aws-redshift"

  # AWS Configuration
  aws_region                  = "us-west-1"
  redshift_cluster_identifier = "my-redshift-cluster"
  name_prefix                 = "my-redshift-audit"
  
  # Input Type: "cloudwatch" or "s3"
  input_type = "cloudwatch"
  
  # Guardium Configuration
  gdp_server             = "guardium.example.com"
  gdp_port               = "8443"
  gdp_username           = "admin"
  gdp_password           = "password"
  gdp_ssh_username       = "root"
  gdp_ssh_privatekeypath = "~/.ssh/guardium_key"
  gdp_client_id          = "client1"
  gdp_client_secret      = "client-secret"
  
  # Universal Connector Configuration
  udc_aws_credential = "aws-credential-name"
  gdp_mu_host        = "guardium-mu.example.com"
  
  # Audit Configuration
  codec_pattern    = "((^'%{TIMESTAMP_ISO8601:timestamp})|(^(?<action>[^:]*) \\|%{DAY:day}\\, %{MONTHDAY:md} %{MONTH:month} %{YEAR:year} %{TIME:time}))"
  csv_event_filter = ""

  tags = {
    Environment = "production"
    Project     = "data-security"
  }
}
```

## Examples

Complete working examples are available in the `examples/` directory:

- [aws-documentdb](examples/aws-documentdb) - DocumentDB audit configuration with Universal Connector
- [aws-dynamodb](examples/aws-dynamodb) - DynamoDB audit configuration with Universal Connector
- [aws-mariadb-rds-audit](examples/aws-mariadb-rds-audit) - MariaDB RDS audit configuration
- [aws-mysql-rds-audit](examples/aws-mysql-rds-audit) - MySQL RDS audit configuration
- [aws-postgresql-rds-object](examples/aws-postgresql-rds-object) - PostgreSQL object-level auditing
- [aws-postgresql-rds-object-tables](examples/aws-postgresql-rds-object-tables) - PostgreSQL object-level auditing with specific tables
- [aws-postgresql-rds-session](examples/aws-postgresql-rds-session) - PostgreSQL session-level auditing
- [aws-redshift-with-uc](examples/aws-redshift-with-uc) - Redshift audit configuration with Universal Connector

Each example includes:
- Complete Terraform configuration
- `terraform.tfvars.example` file with all required variables
- README with specific instructions

## Key Features

- **Automated Configuration**: Automatically configures audit logging for AWS datastores
- **Universal Connector Integration**: Seamlessly integrates with Guardium Universal Connector
- **Multiple Datastore Support**: Supports DynamoDB, DocumentDB, MariaDB RDS, MySQL RDS, and PostgreSQL RDS
- **Flexible Audit Levels**: Choose between object-level and session-level auditing for PostgreSQL
- **CloudWatch Integration**: Leverages CloudWatch Logs for centralized log management
- **Compliance Ready**: Supports compliance requirements (PCI-DSS, HIPAA, GDPR, SOC 2)
- **Terraform Native**: Fully declarative infrastructure as code approach

## Security Considerations

- **Credentials Management**: Store sensitive credentials securely using Terraform variables or secret management solutions
- **State File Security**: Ensure Terraform state files are encrypted and stored securely
- **IAM Permissions**: Follow the principle of least privilege for all IAM roles and policies
- **Network Security**: Configure security groups and network ACLs appropriately
- **Encryption**: Enable encryption for CloudWatch Logs, S3 buckets, and data in transit
- **Access Control**: Implement proper access controls for Guardium and AWS resources

## Troubleshooting

### Common Issues

1. **CloudTrail Not Capturing Events**:
  - Verify CloudTrail is configured with data events for the specific datastore
  - Check IAM permissions for CloudTrail
  - Ensure CloudWatch Log Group is properly configured

2. **Universal Connector Not Processing Logs**:
  - Verify AWS credentials are correctly configured in Guardium
  - Check network connectivity between Guardium and AWS
  - Review Universal Connector logs in Guardium UI

3. **Parameter/Option Group Changes Not Applied**:
  - Some changes require database restart or failover
  - Check the `force_failover` variable setting
  - Review AWS RDS events for any errors

4. **Authentication Errors**:
  - Verify Guardium OAuth client credentials
  - Ensure SSH key has correct permissions (600)
  - Check Guardium user has appropriate permissions

For detailed troubleshooting, refer to the individual module READMEs.

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Support

For issues and questions:
- Create an issue in this repository
- Contact the maintainers listed in [MAINTAINERS.md](MAINTAINERS.md)

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

```text
#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#
```

## Authors

Module is maintained by IBM with help from [these awesome contributors](https://github.com/IBM/terraform-guardium-datastore-va/graphs/contributors).

## Additional Resources

- [IBM Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Guardium Universal Connector Guide](https://www.ibm.com/docs/en/guardium/12.2?topic=connectors-universal-connector)
- [AWS CloudTrail Documentation](https://docs.aws.amazon.com/cloudtrail/)
- [AWS CloudWatch Logs Documentation](https://docs.aws.amazon.com/cloudwatch/latest/logs/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
