resource "azuread_invitation" "user_invitation" {
  user_display_name = var.user_display_name
  user_email_address = var.user_email_address
  redirect_url = var.redirect_url
  user_type = var.user_type
}