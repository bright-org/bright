variable "id" {
  description = "Service Account ID"
  type        = string
}

variable "description" {
  description = "Service Account description"
  type        = string
}

variable "roles" {
  description = "Service Account roles"
  type        = list(string)
}
