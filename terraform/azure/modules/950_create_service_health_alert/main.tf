# Tags (shared across all resources)
variable "common_tags" {
  type = map(string)
  default = {
    environment = "Development"
    owner       = "terraform"
  }
}

# リソースグループ
resource "azurerm_resource_group" "example" {
  name     = "example-rg"
  location = "japaneast"
  tags     = var.common_tags
}

# Azure Monitor Action Group (メール通知先)
resource "azurerm_monitor_action_group" "example" {
  name                = "example-action-group"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "exampleAG"

  email_receiver {
    name                    = "email-notification"
    email_address           = "kawashima.narumi@re-x-expansion.com"  # 通知を受け取るメールアドレス
    use_common_alert_schema = true
  }

  tags = var.common_tags
}

# Service Health Alert（計画メンテナンス & サービスの問題通知）
resource "azurerm_monitor_activity_log_alert" "service_health_alert" {
  name                = "service-health-alert"
  resource_group_name = azurerm_resource_group.example.name
  scopes              = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
  description         = "Notifies when a planned maintenance event or service issue occurs"

  criteria {
    category       = "ServiceHealth"
    operation_name = "Microsoft.ResourceHealth/healthevent/action"
    level          = "Informational"
  }

  action {
    action_group_id = azurerm_monitor_action_group.example.id
  }

  tags     = var.common_tags
}

# 現在のサブスクリプション情報取得
data "azurerm_client_config" "current" {}