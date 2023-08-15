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

variable "google_client_id" {
  description = "Bright Google OAuth2 CLIENT ID"
  type        = string
}

variable "google_client_secret" {
  description = "Bright Google OAuth2 CLIENT SECRET"
  type        = string
}
