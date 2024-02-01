terraform {
  required_version = ">=0.13"

  required_providers {
    azurerm = {
        source = "hasicorp/azurerm"
        version = "3.18.0"
    }
  }
}

provider "azurerm" {
  features {}
}