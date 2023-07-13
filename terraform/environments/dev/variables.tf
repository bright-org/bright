variable "db_password" {
  description = "Cloud SQL database password (defined in Terraform Cloud)"
  type        = string
}

variable "secret_key_base" {
  description = "Bright secret key base"
  type        = string
}

variable "sendgrid_api_key" {
  description = "Bright SendGrid API key"
  type        = string
}
