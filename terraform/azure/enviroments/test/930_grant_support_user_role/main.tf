module "grant_support_user_role" {
  source               = "../../../modules/930_grant_support_user_role"
  user_principal_name  = var.user_principal_name
  role_definition_name = var.role_definition_name
}