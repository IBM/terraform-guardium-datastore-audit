#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

locals {
  # Profiles whose connection test failed on import. These are not deployed.
  failed_profile_names = toset(flatten([
    for r in guardium-data-protection_import_profiles.import_profiles : r.failed_connection_test_profiles
  ]))

  # Read each file and index it by its position in the list so we can create
  # one local_file + one import_profiles resource per CSV.
  csv_files = {
    for idx, path in var.csv_file_paths :
    tostring(idx) => {
      path    = path
      content = file(path)
    }
  }

  # Parse every CSV and collect the "name" column across all files into one
  # flat set.  Each name drives a single install_connector call.
  # All UC profile CSVs share the same header layout:
  #   profile_definition_name, name, description, ...
  profile_names = toset(flatten([
    for f in local.csv_files : [
      for row in csvdecode(f.content) : row["name"]
    ]
  ]))
}

# Write each CSV to the workspace .terraform directory so the provider can
# upload it as a multipart file.  Keyed by list index to avoid name collisions.
resource "local_file" "csv_temp" {
  for_each = var.enable_universal_connector ? local.csv_files : {}
  content  = each.value.content
  filename = "${path.root}/.terraform/uc-csv-import-${each.key}.csv"
}

# Authenticate with Guardium once to obtain an OAuth access token shared
# across all import and install operations.
data "guardium-data-protection_authentication" "access_token" {
  count         = var.enable_universal_connector ? 1 : 0
  client_secret = var.gdp_client_secret
  username      = var.gdp_username
  password      = var.gdp_password
  client_id     = var.gdp_client_id
}

# Import all profiles from each CSV file via multipart upload.
# One upload per file — GDP parses the profile names from the file itself.
resource "guardium-data-protection_import_profiles" "import_profiles" {
  for_each = var.enable_universal_connector ? local.csv_files : {}

  depends_on       = [local_file.csv_temp]
  access_token     = data.guardium-data-protection_authentication.access_token[0].access_token
  path_to_file     = abspath(local_file.csv_temp[each.key].filename)
  update_mode      = true
  test_connections = var.test_connections
}

# Deploy every imported profile onto the specified Managed Units.
# One install_connector call per unique profile name across all uploaded files.
# Profiles whose connection test failed on import are skipped (with a warning) so that
# the remaining profiles are still deployed.
resource "guardium-data-protection_install_connector" "install_connector" {
  for_each = var.enable_universal_connector ? local.profile_names : toset([])

  depends_on    = [guardium-data-protection_import_profiles.import_profiles]
  access_token  = data.guardium-data-protection_authentication.access_token[0].access_token
  udc_name      = each.key
  gdp_mu_host   = var.gdp_mu_host
  skip_profiles = flatten([for r in guardium-data-protection_import_profiles.import_profiles : r.failed_connection_test_profiles])
}
