variable "account_enabled" {
  description = "Whether or not the support account should be enabled."
  type        = bool
}

variable "display_name" {
  description = "The name to display in the address book for the user."
  type        = string
}

variable "onpremises_immutable_id" {
  description = "The value used to associate an on-premise Active Directory user account with their Azure AD user object."
  type        = string
}

variable "mail_nickname" {
  description = "The mail alias for the user. Defaults to the user name part of the user principal name."
  type        = string
}

variable "force_password_change" {
  description = "Whether the user is forced to change the password during the next sign-in."
  type        = bool
}

variable "password" {
  description = "The password for the user."
  type        = string
}

variable "user_principal_name" {
  description = "The user principal name (UPN) of the user."
  type        = string
}