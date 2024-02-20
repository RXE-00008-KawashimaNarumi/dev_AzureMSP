data "azurerm_subscription" "import_subscription" {

}

data "azuread_user" "import_user" {
    user_principal_name = var.role_user_principal_name
}

resource "azurerm_role_assignment" "role_assignment" {
  scope                = data.azurerm_subscription.import_subscription.id
  role_definition_name = var.role_definition_name
  principal_id         = data.azuread_user.import_user.object_id
}

