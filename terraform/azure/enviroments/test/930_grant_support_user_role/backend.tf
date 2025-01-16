terraform {
  backend "azurerm" {
    resource_group_name  = "terraform_setup"
    storage_account_name = "XXXXXXXXXX"
    container_name       = "tfstate"
  }
}