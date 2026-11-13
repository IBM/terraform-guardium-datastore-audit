#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.0"
    }

    guardium-data-protection = {
      source  = "IBM/guardium-data-protection"
      version = "= 1.4.10"
    }
  }
}
