## user create
variable "user_principal_name" {
  description = "support acount name"
}

variable "display_name" {
    description = "support acount display name"
}

variable "password" {
  description = "support acount password"
}

## user invitation
variable "user_display_name" {
  description = "invitate user display name"
}

variable "user_email_address" {
  description = "invitate email address"
}

variable "redirect_url" {
  description = "invitate redirect URL"
}

variable "user_type" {
  description = "invitate user type"
}