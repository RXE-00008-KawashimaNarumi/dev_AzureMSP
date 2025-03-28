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

# Resource Group
resource "azurerm_resource_group" "az_rg" {
  name     = "resource-group-001"
  location = "japaneast"
  tags     = var.common_tags
}

# Virtual Network
resource "azurerm_virtual_network" "az_vn" {
  name                = "network-001"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.common_tags
}

# Subnet
resource "azurerm_subnet" "az_su" {
  name                 = "subnet-001"
  resource_group_name  = azurerm_resource_group.az_rg.name
  virtual_network_name = azurerm_virtual_network.az_vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Interface
resource "azurerm_network_interface" "az_ni" {
  name                = "nic-001"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.az_su.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.common_tags
}

# Network Security Group with SSH Rule
resource "azurerm_network_security_group" "az_nsg" {
  name                = "nsg-001"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "49.129.188.39/32"
    destination_address_prefix = "*"
  }

  tags = var.common_tags
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "az_nisga" {
  network_interface_id      = azurerm_network_interface.az_ni.id
  network_security_group_id = azurerm_network_security_group.az_nsg.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "az_lvm" {
  name                = "vm-ubuntu-001"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  size                = "Standard_B1s"

  network_interface_ids = [
    azurerm_network_interface.az_ni.id
  ]

  admin_username                  = "azureuser"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    name                 = "os-disk-vm-ubuntu-001"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18_04-lts-gen2"
    version   = "latest"
  }

  computer_name = "vm-ubuntu-001"

  tags = var.common_tags
}

# Install Azure Monitor Agent (Linux)
resource "azurerm_virtual_machine_extension" "az_vme" {
  name                 = "AzureMonitorLinuxAgent"
  virtual_machine_id   = azurerm_linux_virtual_machine.az_lvm.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.33"
  settings             = jsonencode({})

  depends_on = [azurerm_linux_virtual_machine.az_lvm]
}

# Data Collection Endpoint（DCE）
resource "azurerm_monitor_data_collection_endpoint" "az_mdce" {
  name                = "vm-dce-metrics-001"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  kind                = "Linux"
}

# Create DCR (Data Collection Rule)
resource "azurerm_monitor_data_collection_rule" "az_mdcr" {
  name                = "vm-dcr-metrics-001"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  kind                = "Linux"

  data_sources {
    performance_counter {
      name                          = "vm-metrics-001"
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "/builtin/processor/percentidletime",
        "/builtin/processor/percentprocessortime",
        "/builtin/memory/availablememory",
        "/builtin/filesystem/percentusedspace"
      ]
    }
  }

  destinations {
    azure_monitor_metrics {
      name = "destination1"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["destination1"]
  }

  tags = var.common_tags
}

# DCR Association to VM
resource "azurerm_monitor_data_collection_rule_association" "az_mdcra" {
  name                    = "vm-dcr-association"
  target_resource_id      = azurerm_linux_virtual_machine.az_lvm.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.az_mdcr.id
}

# Create Dashboard (CPU&Memory&Disk)
resource "azurerm_portal_dashboard" "az_pd" {
  name                = "dashboard-001"
  resource_group_name = azurerm_resource_group.az_rg.name
  location            = azurerm_resource_group.az_rg.location

  tags = {
    "hidden-title" = "dashboard-001"
  }

  dashboard_properties = jsonencode({
    lenses = [
      {
        order = 0
        parts = [
          {
            position = {
              x       = 0
              y       = 0
              colSpan = 11
              rowSpan = 5
            }
            metadata = {
              inputs = [
                {
                  name       = "options"
                  isOptional = true
                },
                {
                  name       = "sharedTimeRange"
                  isOptional = true
                }
              ]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
              settings = {
                content = {
                  options = {
                    chart = {
                      metrics = [
                        {
                          resourceMetadata = {
                            id = "/subscriptions/${data.azurerm_client_config.az_cc.subscription_id}/resourceGroups/${azurerm_resource_group.az_rg.name}/providers/Microsoft.Compute/virtualMachines/${azurerm_linux_virtual_machine.az_lvm.name}"
                          }
                          name            = "Percentage CPU"
                          aggregationType = 4
                          namespace       = "microsoft.compute/virtualmachines"
                          metricVisualization = {
                            displayName         = "Percentage CPU"
                            resourceDisplayName = "${azurerm_linux_virtual_machine.az_lvm.name}"
                          }
                        }
                      ]
                      title     = "CPU Utilization"
                      titleKind = 2
                      visualization = {
                        chartType = 2
                        legendVisualization = {
                          isVisible      = true
                          position       = 2
                          hideHoverCard  = false
                          hideLabelNames = true
                        }
                        axisVisualization = {
                          x = {
                            isVisible = true
                            axisType  = 2
                          }
                          y = {
                            isVisible = true
                            axisType  = 1
                          }
                        }
                        disablePinning = true
                      }
                    }
                  }
                }
              }
            }
          },
          {
            position = {
              x       = 0
              y       = 5
              colSpan = 11
              rowSpan = 5
            }
            metadata = {
              inputs = [
                {
                  name       = "options"
                  isOptional = true
                },
                {
                  name       = "sharedTimeRange"
                  isOptional = true
                }
              ]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
              settings = {
                content = {
                  options = {
                    chart = {
                      metrics = [
                        {
                          resourceMetadata = {
                            id = "/subscriptions/${data.azurerm_client_config.az_cc.subscription_id}/resourceGroups/${azurerm_resource_group.az_rg.name}/providers/Microsoft.Compute/virtualMachines/${azurerm_linux_virtual_machine.az_lvm.name}"
                          }
                          name            = "Available Memory Bytes"
                          aggregationType = 4
                          namespace       = "microsoft.compute/virtualmachines"
                          metricVisualization = {
                            displayName         = "Available Memory Bytes (Preview)"
                            resourceDisplayName = "${azurerm_linux_virtual_machine.az_lvm.name}"
                          }
                        }
                      ]
                      title     = "Memory Utilization"
                      titleKind = 2
                      visualization = {
                        chartType = 2
                        legendVisualization = {
                          isVisible      = true
                          position       = 2
                          hideHoverCard  = false
                          hideLabelNames = true
                        }
                        axisVisualization = {
                          x = {
                            isVisible = true
                            axisType  = 2
                          }
                          y = {
                            isVisible = true
                            axisType  = 1
                          }
                        }
                        disablePinning = true
                      }
                    }
                  }
                }
              }
            }
          }
        ]
      }
    ]
    metadata = {
      model = {
        timeRange = {
          value = {
            relative = {
              duration = 24
              timeUnit = 1
            }
          }
          type = "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        }
        filterLocale = {
          value = "ja-jp"
        }
        filters = {
          value = {
            MsPortalFx_TimeRange = {
              model = {
                format      = "utc"
                granularity = "auto"
                relative    = "24h"
              }
              displayCache = {
                name  = "UTC 時間"
                value = "過去 24 時間"
              }
              filteredPartIds = [
                "StartboardPart-MonitorChartPart-50a12168-c114-4b5d-b5a6-37307862d16e",
                "StartboardPart-MonitorChartPart-50a12168-c114-4b5d-b5a6-37307862d24b"
              ]
            }
          }
        }
      }
    }
  })
}

# Resource Health Action Group
resource "azurerm_monitor_action_group" "az_mag" {
  name                = "resource-health-action-group-001"
  resource_group_name = azurerm_resource_group.az_rg.name
  short_name          = "rhAG-001"

  email_receiver {
    name                    = "admin-email"
    email_address           = "kawashima.narumi@re-x-expansion.com"
    use_common_alert_schema = true
  }

  tags = var.common_tags
}

# Alert Rule for VM Availability based on Resource Health (Non-Available Alert Notification)
resource "azurerm_monitor_activity_log_alert" "az_mala" {
  name                = "vm-not-available-health-alert"
  resource_group_name = azurerm_resource_group.az_rg.name
  scopes              = [azurerm_linux_virtual_machine.az_lvm.id]
  description         = "Alert when VM is not Available based on Resource Health"

  criteria {
    category       = "ResourceHealth"
    operation_name = "Microsoft.ResourceHealth/healthevent/Activated/action"
  }

  action {
    action_group_id = azurerm_monitor_action_group.az_mag.id
  }

  tags = var.common_tags
}

