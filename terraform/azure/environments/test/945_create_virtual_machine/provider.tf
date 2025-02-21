terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.90.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_delection_if_contains_resources = false
    }
  }
}