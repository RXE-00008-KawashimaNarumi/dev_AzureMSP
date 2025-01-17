# Tags (shared across all resources)
variable "common_tags" {
  type = map(string)
  default = {
    environment = "Development"
    owner       = "Team XYZ"
  }
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "Japan East"
  tags     = var.common_tags
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.common_tags
}

# Subnet
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Interface
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.common_tags
}

# Network Security Group with SSH Rule
resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

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
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# Virtual Machine
resource "azurerm_virtual_machine" "example" {
  name                  = "example-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "example-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "examplevm"
    admin_username = "azureuser"
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.common_tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "example" {
  name                = "example-law"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Free"
  retention_in_days   = 30
  tags                = var.common_tags
}

# Data Collection Rule (Azure Monitor Agent)
resource "azurerm_monitor_data_collection_rule" "example" {
  name                = "example-dcr"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  description         = "Data Collection Rule for Azure Monitor Agent"

  data_sources {
    performance_counter {
      name                = "performance-counters"
      streams             = ["Microsoft-PerformanceCounter"]
      counter_specifiers  = ["\\Processor(_Total)\\% Processor Time"]
      sampling_frequency_in_seconds = 15
    }
  }

  destinations {
    log_analytics {
      name                = "loganalytics-destination"
      workspace_resource_id = azurerm_log_analytics_workspace.example.id
    }
  }

  data_flow {
    streams = ["Microsoft-PerformanceCounter"]
    destinations = ["loganalytics-destination"]
  }

  tags = var.common_tags
}

# Associate Data Collection Rule with VM
resource "azurerm_monitor_data_collection_rule_association" "example" {
  name                   = "example-dcra"
  data_collection_rule_id = azurerm_monitor_data_collection_rule.example.id
  target_resource_id      = azurerm_virtual_machine.example.id
}

# Custom Dashboard
resource "azurerm_portal_dashboard" "example" {
  name                = "example-dashboard"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  dashboard_properties = jsonencode({
    "lenses" : {
      "0" : {
        "order" : 0,
        "parts" : {
          "0" : {
            "position" : {
              "x" : 0,
              "y" : 0,
              "colSpan" : 3,
              "rowSpan" : 4
            },
            "metadata" : {
              "inputs" : [
                {
                  "name" : "resourceType",
                  "value" : "Microsoft.Compute/virtualMachines"
                },
                {
                  "name" : "resourceId",
                  "value" : azurerm_virtual_machine.example.id
                }
              ],
              "type" : "Extension/Metrics"
            }
          }
        }
      }
    },
    "metadata" : {
      "model" : {
        "timeRange" : {
          "value" : {
            "relative" : {
              "duration" : 24,
              "timeUnit" : 1
            }
          },
          "type" : "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        }
      }
    }
  })

  tags = var.common_tags
}
