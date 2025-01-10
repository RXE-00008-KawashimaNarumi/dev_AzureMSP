## user invitation
variable "user_display_name" {
  description = "invitate user display name"
  type        = string
}

variable "user_email_address" {
  description = "invitate email address"
  type        = string
}

variable "redirect_url" {
  description = "invitate redirect URL"
  type        = string
}

variable "user_type" {
  description = "invitate user type"
  type        = string
}

variable "additional_recipients" {
  description = "send email address"
  type        = list(string)
}