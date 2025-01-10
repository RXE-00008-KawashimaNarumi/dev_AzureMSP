resource "azurerm_kubernetes_cluster" "aks" {
    name                = var.name
    location            = var.location
    resource_group_name = var.resource_group_name
    dns_prefix          = "aks-${var.name}-dns"
    kubernetes_version  = "${var.kubernetes_version}"
    default_node_pool {
        name                   = "nodepool"
        zones                  = ["1","2","3"]
        node_count             = var.default_node_pool_node_count
        vm_size                = var.default_node_pool_vm_size
        max_pods               = "200"
        enable_auto_scaling    = var.default_node_pool_auto_scaling
        # If enable_auto_scaling is set to true, max_count and min_count is required.
        max_count              = var.default_node_pool_max_count
        min_count              = var.default_node_pool_min_count
    }
    network_profile {
        network_plugin     = var.network_plugin
        ip_versions        = var.ip_versions
    }
    identity {
        type = "SystemAssigned"
    }
}
resource "azurerm_kubernetes_cluster_node_pool" "secondnodepool" {
    count = var.second_node_pool_enabled
    name                   = "nodepool2"
    kubernetes_cluster_id  = azurerm_kubernetes_cluster.aks.id
    node_count             = var.second_node_pool_node_count
    vm_size                = var.second_node_pool_vm_size
    max_pods               = "200"
    enable_auto_scaling    = var.second_node_pool_auto_scaling
    # If enable_auto_scaling is set to true, max_count and min_count is required.
    max_count              = var.second_node_pool_max_count
    min_count              = var.second_node_pool_min_count
}