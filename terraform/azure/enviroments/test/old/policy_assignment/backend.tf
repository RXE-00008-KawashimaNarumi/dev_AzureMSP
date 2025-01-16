terraform {
  backend "azurerm" {
    resource_group_name = "azuremsp"
    storage_account_name = "azuremsp0711"
    container_name = "tfstate"
  }
}