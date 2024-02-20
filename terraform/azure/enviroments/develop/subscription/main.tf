#module "create_supprt_acount" {
#  source = "../../../modules/user"
#  user_principal_name = "${var.user_principal_name}"
#  display_name = "${var.display_name}"
#  password = "${var.password}"
#}

#module "user_invitation" {
#  source = "../../../modules/user_invitation"
#  user_display_name = "${var.user_display_name}"
#  user_email_address = "${var.user_email_address}"
#  redirect_url = "${var.redirect_url}"
#  user_type = "${var.user_type}"
#  additional_recipients = "${var.additional_recipients}"
#}


module "role_assignment" {
  source = "../../../modules/role_assignment"
  subscription_id = "${var.subscription_id}"
  role_user_principal_name = "${var.role_user_principal_name}"
  role_definition_name = "${var.role_definition_name}"
}
