variable "name" {
  description = "Cloud SQL instance name"
  type        = string
  default     = "instance"
}

variable "database_version" {
  description = "Cloud SQL instance database version"
  type        = string
  default     = "POSTGRES_15"
}

variable "region" {
  description = "Cloud SQL instance region"
  type        = string
  default     = "asia-northeast1"
}

variable "availability_type" {
  description = "Cloud SQL instance availability type (`REGIONAL` or `ZONAL`)"
  type        = string
}

variable "tier" {
  description = "Cloud SQL instance tier"
  type        = string
}

variable "database" {
  description = "Cloud SQL database name"
  type        = string
  default     = "bright"
}

variable "username" {
  description = "Cloud SQL database user"
  type        = string
  default     = "bright"
}

variable "password" {
  description = "Cloud SQL database password"
  type        = string
}
