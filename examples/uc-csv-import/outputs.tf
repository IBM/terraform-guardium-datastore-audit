#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

# The lists are comma-separated strings so that the CLI prints them on a single line,
# e.g. "a, b", instead of one element per line.
output "profile_names" {
  description = "All Universal Connector profile names extracted from the CSV files, including any that were not deployed (see skipped_profiles), as a comma-separated string"
  value       = join(", ", sort(tolist(module.uc_csv_import.profile_names)))
}

output "deployed_profiles" {
  description = "Profile names that were deployed on the collector(s), as a comma-separated string"
  value       = join(", ", sort(tolist(module.uc_csv_import.deployed_profiles)))
}

output "skipped_profiles" {
  description = "Profile names that were NOT deployed because their connection test failed on import, as a comma-separated string (empty if none)"
  value       = join(", ", sort(tolist(module.uc_csv_import.skipped_profiles)))
}

output "csv_file_paths" {
  description = "CSV file paths that were imported, in the order given, as a comma-separated string"
  value       = join(", ", module.uc_csv_import.csv_file_paths)
}
