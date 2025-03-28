module "create_support_account" {
  source                  = "../../../modules/901_create_support_account"
  account_enabled         = var.account_enabled
  display_name            = var.display_name
  onpremises_immutable_id = var.onpremises_immutable_id
  mail_nickname           = var.mail_nickname
  force_password_change   = var.force_password_change
  password                = var.password
  user_principal_name     = var.user_principal_name
}