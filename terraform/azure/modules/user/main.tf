resource "azuread_user" "create_supprt_acount" {
    user_principal_name = var.user_principal_name
    display_name = var.display_name
    password = var.password
}

resource "azuread_invitation" "user_invitation" {
  user_display_name = var.user_principal_name
  user_email_address = var.user_email_address
  redirect_url = var.redirect_url
  user_type = var.user_type
}