# PostgreSQL RDS Table Grants Example

This example demonstrates how to configure table-specific grants for the PostgreSQL RDS audit configuration.

## Usage

To use this example, include the `tables` variable in your module configuration:

```hcl
module "datastore-audit_aws-postgresql-rds-object" {
  source = "IBM/datastore-audit/guardium//modules/aws-postgresql-rds-object"
  
  # Basic configuration
  aws_region                     = "us-east-1"
  postgres_rds_cluster_identifier = "my-postgres-cluster"
  db_host                        = "my-postgres-instance.abcdefg.us-east-1.rds.amazonaws.com"
  db_port                        = 5432
  db_username                    = "admin"
  db_password                    = "securepassword"
  db_name                        = "postgres"
  
  # Table grants configuration
  tables = [
    {
      schema = "public"
      table  = "users"
      grants = ["SELECT", "INSERT", "UPDATE"]
    },
    {
      schema = "app_schema"
      table  = "transactions"
      grants = ["SELECT"]
    }
  ]
  
  # Other required variables...
}
```

## Variable Format

The `tables` variable accepts a list of objects with the following structure:

```hcl
tables = [
  {
    schema = string       # The schema name containing the table
    table  = string       # The table name to grant permissions on
    grants = list(string) # List of permissions to grant
  }
]
```

### Valid Grant Types

The following grant types are supported:
- SELECT
- INSERT
- UPDATE
- DELETE
- REFERENCES
- TRIGGER
- ALL

## Using with Variable Files

You can also define your table grants in a separate `.tfvars` file:

```
terraform apply -var-file="table_grants.tfvars"
```

See the `table_grants.tfvars` file in this directory for an example.
