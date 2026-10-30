#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "profile_names" {
  description = "Set of all Universal Connector profile names extracted from the CSV files, including any that were not deployed (see skipped_profiles)"
  value       = local.profile_names
}

output "deployed_profiles" {
  description = "Set of profile names that were deployed on the collector(s) (empty when enable_universal_connector is false)"
  value       = var.enable_universal_connector ? setsubtract(local.profile_names, local.failed_profile_names) : toset([])
}

output "skipped_profiles" {
  description = "Set of profile names that were NOT deployed because their connection test failed on import"
  value       = setintersection(local.profile_names, local.failed_profile_names)
}

output "csv_file_paths" {
  description = "List of CSV file paths that were imported"
  value       = var.csv_file_paths
}
