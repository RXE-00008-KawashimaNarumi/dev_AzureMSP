# Tags (shared across all resources)
variable "common_tags" {
  type = map(string)
  default = {
    environment = "test"
    owner       = "terraform"
  }
}

# get current Azure subscription configuration
data "azurerm_client_config" "az_cc" {}

# リソースグループ
resource "azurerm_resource_group" "az_rg" {
  name     = "rg-service-health"
  location = "japaneast"
  tags     = var.common_tags
}

# Create Azure Monitor Action Group 
resource "azurerm_monitor_action_group" "az_mag" {
  name                = "service-health-action-group-001"
  resource_group_name = azurerm_resource_group.az_rg.name
  short_name          = "servicehealthAG-001"

  email_receiver {
    name                    = "email-notification"
    email_address           = "kawashima.narumi@re-x-expansion.com"
    use_common_alert_schema = true
  }

  tags = var.common_tags
}

# Alert Rule for Service Health (Planned Maintenance and Service Issues Notification)
resource "azurerm_monitor_activity_log_alert" "service_health_alert" {
  name                = "service-health-alert"
  resource_group_name = azurerm_resource_group.az_rg.name
  scopes              = ["/subscriptions/${data.azurerm_client_config.az_cc.subscription_id}"]
  description         = "Notifies when a planned maintenance event or service issue occurs"

  criteria {
    category       = "ServiceHealth"
    operation_name = "Microsoft.ResourceHealth/healthevent/action"
    level          = "Informational"
  }

  action {
    action_group_id = azurerm_monitor_action_group.az_mag.id
  }

  tags = var.common_tags
}
