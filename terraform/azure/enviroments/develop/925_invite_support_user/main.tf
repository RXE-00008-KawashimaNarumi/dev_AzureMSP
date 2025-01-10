module "invite_support_user" {
  source                = "../../../modules/925_invite_support_user"
  user_display_name     = var.user_display_name
  user_email_address    = var.user_email_address
  redirect_url          = var.redirect_url
  user_type             = var.user_type
  additional_recipients = var.additional_recipients
}