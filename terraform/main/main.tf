module "rg" {
source = "../azure/modules/resource_group"
name = "rg-${var.id}"
location = var.location
}
module "aks" {
source = "../azure/modules/kubernetes"
# common kubernetes config
location = var.location
resource_group_name = module.rg.name
name = "aks-${var.id}"
kubernetes_version = var.kubernetes_version
network_plugin = "azure"
ip_versions = ["IPv4"]
# default node_pool config
default_node_pool_auto_scaling = true
default_node_pool_node_count = 3
default_node_pool_vm_size ="Standard_E4a_v4"
default_node_pool_max_count = 5
default_node_pool_min_count = 1
# second node_pool config
second_node_pool_enabled = var.second_node_pool_enabled ? 1 : 0
second_node_pool_auto_scaling = true
second_node_pool_node_count = 3
second_node_pool_vm_size = "Standard_DS2_v2"
second_node_pool_max_count = 5
second_node_pool_min_count = 1
depends_on = [module.rg.rg]
}
