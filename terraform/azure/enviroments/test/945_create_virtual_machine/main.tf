module "create_virtual_machine" {
  source                  = "../../../modules/945_create_virtual_machine"
  admin_password         = var.admin_password
}