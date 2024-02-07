variable "location" {}
variable "resource_group_name" {}
variable "kubernetes_version" {
    default = "1.26.3"
}
variable "name" {}
variable "default_node_pool_node_count" {
  default = 3
}
variable "default_node_pool_vm_size" {
  default = "Standard_DS2_v2"
}
variable "default_node_pool_max_count" {
  default = 3
}
variable "default_node_pool_min_count" {
  default = 3
}
variable "default_node_pool_auto_scaling" {
    default = false
}
variable "second_node_pool_enabled" {
  default = 0
}
variable "second_node_pool_node_count" {
  default = 3
}
variable "second_node_pool_vm_size" {
  default = "Standard_DS2_v2"
}
variable "second_node_pool_max_count" {
  default = 3
}
variable "second_node_pool_min_count" {
  default = 3
}
variable "second_node_pool_auto_scaling" {
    default = false
}
variable "network_plugin" {
    default = "azure"
}
variable "ip_versions" {
    default = ["IPv4"]
}
variable "network_policy" {
    default = null
}