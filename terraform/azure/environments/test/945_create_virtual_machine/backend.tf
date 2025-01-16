terraform {
  backend "azurerm" {
    resource_group_name  = "terraform_setup"
    storage_account_name = "terraformsetup20250110"
    container_name       = "tfstate"
  }
}