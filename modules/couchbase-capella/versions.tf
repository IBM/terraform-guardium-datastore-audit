# Terraform and Provider Version Requirements

terraform {
  required_version = ">= 0.13"

  required_providers {
    couchbase-capella = {
      source  = "couchbasecloud/couchbase-capella"
      version = ">= 1.2.0"
    }
    guardium-data-protection = {
      source  = "IBM/guardium-data-protection"
      version = ">= 1.0.0"
    }
  }
}

provider "couchbase-capella" {
  authentication_token = var.capella_api_token
  host = var.capella_api_host
  global_api_request_timeout = 600
}


# Configure the Couchbase Capella Provider
# Authentication token should be set via environment variable CAPELLA_TOKEN
# or passed through the provider configuration

# Configure the Guardium Data Protection Provider
provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}