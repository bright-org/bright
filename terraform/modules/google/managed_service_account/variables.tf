variable "id" {
  description = "Managed Service Account ID"
  type        = string
}

variable "roles" {
  description = "Managed Service Account roles"
  type        = list(string)
}
