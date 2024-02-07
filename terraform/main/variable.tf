variable "id" {}
variable "location" {}
variable "kubernetes_version" {
    default = null
}
variable "second_node_pool_enabled" {
    type = bool
    default = false
}