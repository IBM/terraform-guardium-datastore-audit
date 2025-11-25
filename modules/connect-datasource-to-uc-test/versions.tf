terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    guardium-data-protection = {
      source = "IBM/guardium-data-protection"
      version = ">= 1.0.0"
    }
  }
}
