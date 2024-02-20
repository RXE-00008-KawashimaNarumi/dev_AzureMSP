module "role_assignment" {
  source = "../../../modules/role_assignment"
  subscription_id = "${var.subscription_id}"
  role_user_principal_name = "${var.role_user_principal_name}"
  role_definition_name = "${var.role_definition_name}"
}
