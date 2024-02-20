data "azurerm_subscription" "import_subscription" {}

resource "azurerm_policy_definition" "policy_def" {
  name         = "only-deploy-location"
  policy_type  = "BuiltIn"
  mode         = "Indexed"
  display_name = "Allowed Location"

  policy_rule = <<POLICY_RULE
 {
    "if": {
      "allOf": [
       {
         "field": "location",
         "notIn": ["japaneast", "japanwest"]
       },
       {
         "field": "location",
         "notEquals": "global"
       },
       {
       "field" "type",
       "notEquals": "Microsoft.AzureActiveDirectory/b2cDirectories"
       }
      ]
    },
    "then": {
      "effect": "deny"
    }
  }
POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "policy_assign" {
  name                 = "allow_location_subsucription_policy_assign"
  policy_definition_id = azurerm_policy_definition.policy_def.id
  subscription_id      = data.azurerm_subscinn.import_subscription.id
}


