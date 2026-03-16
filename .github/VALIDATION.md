# Terraform Validation

Automated validation to prevent AWS naming errors and ensure code quality.

## What It Does

✅ **Terraform Format** - Checks code formatting  
✅ **Terraform Validate** - Validates all 10 modules  
✅ **AWS Naming** - Prevents underscore errors in S3/parameter groups  
✅ **TFLint** - Lints for best practices  
✅ **Security Scan** - Checks with Checkov  
✅ **Terraform Plan** - Tests example configurations

## The Problem We Solved

**Error**: `InvalidBucketName: The specified bucket is not valid`

**Cause**: S3 buckets and parameter groups don't allow underscores

**Example**:
- ❌ `guardium-devan_test_e2e-cloudtrail` (has underscore)
- ✅ `guardium-devan-test-e2e-cloudtrail` (sanitized)

## Run Locally

```bash
# Quick validation
.github/scripts/validate-naming.sh

# Format code
terraform fmt -recursive

# Validate a module
cd modules/aws-dynamodb
terraform init -backend=false
terraform validate
```

## GitHub Actions

Runs automatically on every PR and push to main.

View results in the Actions tab or PR checks.

## Adding New Modules

If your module creates S3 buckets or parameter groups:

```hcl
locals {
  sanitized_name_prefix = replace(var.name_prefix, "_", "-")
  bucket_name = "${local.sanitized_name_prefix}-suffix"
}
```

That's it!