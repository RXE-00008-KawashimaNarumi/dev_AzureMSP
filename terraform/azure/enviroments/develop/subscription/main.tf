#module "create_suport_acount" {
#  source = "../../../modules/user"
#  user_principal_name = var.user_principal_name
#  display_name = var.display_name
#}

module "tf-plan" {
  source = "../../../modules/user"
  name = var.name
  location = var.location
}