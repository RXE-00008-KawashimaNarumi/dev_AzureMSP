module "role_assignment" {
  source = "../../../modules/role_assignment"
  role_user_principal_name = "${var.role_user_principal_name}"
  role_definition_name = "${var.role_definition_name}"
}
