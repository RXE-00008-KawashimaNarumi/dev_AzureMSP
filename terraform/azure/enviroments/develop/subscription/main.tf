module "create_support_acount" {
  source = "../../../modules/user"
  user_principal_name = "${var.user_principal_name}"
  display_name = "${var.display_name}"
  password = "${var.password}"
}


module "user_invitation" {
  source = "../../../modules/user"
  user_display_name = "${var.user_display_name}"
  user_email_address = "${var.user_email_address}"
  redirect_url = "${var.redirect_url}"
  user_type = "${var.user_type}"
}

