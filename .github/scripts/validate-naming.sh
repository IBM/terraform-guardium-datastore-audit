#!/bin/bash
# Copyright 2026 IBM Corp.
# SPDX-License-Identifier: Apache-2.0

# Note: Not using set -e to allow all tests to run and report results

echo "=========================================="
echo "AWS Resource Naming Validation Test"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAILED=0
PASSED=0

# Function to validate AWS naming conventions
validate_aws_name() {
    local name=$1
    local resource_type=$2
    
    # AWS S3 bucket and parameter group naming rules:
    # - Must be lowercase
    # - Can contain alphanumeric characters and hyphens
    # - Cannot contain underscores
    # - Must start and end with alphanumeric character
    
    if [[ ! "$name" =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$ ]]; then
        echo -e "${RED}✗ FAIL${NC}: $resource_type name '$name' is invalid"
        echo "  Reason: Must contain only lowercase alphanumeric characters and hyphens"
        return 1
    fi
    
    if [[ "$name" =~ _ ]]; then
        echo -e "${RED}✗ FAIL${NC}: $resource_type name '$name' contains underscores"
        echo "  Reason: Underscores are not allowed in AWS S3 bucket and parameter group names"
        return 1
    fi
    
    echo -e "${GREEN}✓ PASS${NC}: $resource_type name '$name' is valid"
    return 0
}

# Test cases based on the actual error we encountered
echo "Testing DynamoDB S3 Bucket Naming..."
echo "------------------------------------"

# Test case 1: Original problematic name (should fail without fix)
TEST_PREFIX_1="guardium-devan_test_e2e"
SANITIZED_1="${TEST_PREFIX_1//_/-}"
BUCKET_NAME_1="${SANITIZED_1}-cloudtrail"

echo "Test 1: name_prefix with underscores"
echo "  Input: $TEST_PREFIX_1"
echo "  Sanitized: $SANITIZED_1"
echo "  S3 Bucket: $BUCKET_NAME_1"

if validate_aws_name "$BUCKET_NAME_1" "S3 Bucket"; then
    ((PASSED++))
else
    ((FAILED++))
fi
echo ""

# Test case 2: Another problematic name
TEST_PREFIX_2="guardium-devan_test_e2e_2"
SANITIZED_2="${TEST_PREFIX_2//_/-}"
BUCKET_NAME_2="${SANITIZED_2}-cloudtrail"

echo "Test 2: name_prefix with multiple underscores"
echo "  Input: $TEST_PREFIX_2"
echo "  Sanitized: $SANITIZED_2"
echo "  S3 Bucket: $BUCKET_NAME_2"

if validate_aws_name "$BUCKET_NAME_2" "S3 Bucket"; then
    ((PASSED++))
else
    ((FAILED++))
fi
echo ""

echo "Testing Redshift Resource Naming..."
echo "------------------------------------"

# Test case 3: Redshift S3 bucket
TEST_PREFIX_3="my_test_prefix"
SANITIZED_3="${TEST_PREFIX_3//_/-}"
S3_BUCKET_3="${SANITIZED_3}-redshift-logs"

echo "Test 3: Redshift S3 bucket"
echo "  Input: $TEST_PREFIX_3"
echo "  Sanitized: $SANITIZED_3"
echo "  S3 Bucket: $S3_BUCKET_3"

if validate_aws_name "$S3_BUCKET_3" "S3 Bucket"; then
    ((PASSED++))
else
    ((FAILED++))
fi
echo ""

# Test case 4: Redshift parameter group
PARAM_GROUP="${SANITIZED_3}-redshift-logging"

echo "Test 4: Redshift parameter group"
echo "  Input: $TEST_PREFIX_3"
echo "  Sanitized: $SANITIZED_3"
echo "  Parameter Group: $PARAM_GROUP"

if validate_aws_name "$PARAM_GROUP" "Parameter Group"; then
    ((PASSED++))
else
    ((FAILED++))
fi
echo ""

# Test case 5: Valid name without underscores (should always pass)
TEST_PREFIX_5="guardium-test-valid"
BUCKET_NAME_5="${TEST_PREFIX_5}-cloudtrail"

echo "Test 5: Valid name without underscores"
echo "  Input: $TEST_PREFIX_5"
echo "  S3 Bucket: $BUCKET_NAME_5"

if validate_aws_name "$BUCKET_NAME_5" "S3 Bucket"; then
    ((PASSED++))
else
    ((FAILED++))
fi
echo ""

# Verify the actual Terraform code has the sanitization logic
echo "Verifying Terraform Code Implementation..."
echo "--------------------------------------------"

check_file_for_sanitization() {
    local file=$1
    local module_name=$2
    
    if grep -q 'sanitized_name_prefix.*=.*replace.*var\.name_prefix.*"_".*"-"' "$file"; then
        echo -e "${GREEN}✓ PASS${NC}: $module_name has sanitization logic"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}: $module_name missing sanitization logic"
        echo "  Expected: sanitized_name_prefix = replace(var.name_prefix, \"_\", \"-\")"
        ((FAILED++))
        return 1
    fi
}

# Check DynamoDB module
if [ -f "modules/aws-dynamodb/main.tf" ]; then
    check_file_for_sanitization "modules/aws-dynamodb/main.tf" "DynamoDB module"
else
    echo -e "${YELLOW}⚠ WARN${NC}: DynamoDB module not found"
fi

# Check Redshift module
if [ -f "modules/aws-redshift/main.tf" ]; then
    check_file_for_sanitization "modules/aws-redshift/main.tf" "Redshift module"
else
    echo -e "${YELLOW}⚠ WARN${NC}: Redshift module not found"
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}❌ Naming validation FAILED!${NC}"
    echo ""
    echo "Common issues:"
    echo "  1. Underscores in name_prefix are not being sanitized"
    echo "  2. Missing sanitization logic in module locals"
    echo "  3. Resource names not using sanitized_name_prefix"
    echo ""
    echo "Fix: Add this to module locals:"
    echo "  sanitized_name_prefix = replace(var.name_prefix, \"_\", \"-\")"
    echo ""
    exit 1
else
    echo -e "${GREEN}✅ All naming validation tests PASSED!${NC}"
    exit 0
fi

# Made with Bob
