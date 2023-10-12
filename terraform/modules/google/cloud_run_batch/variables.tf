variable "name" {
  description = "Cloud Run Job name"
  type        = string
}

variable "location" {
  description = "Cloud Run Job location"
  type        = string
  default     = "asia-northeast1"
}

variable "timeout_seconds" {
  description = "Cloud Run Job timeout seconds"
  type        = number
  default     = 60 * 60 # 1時間
}

variable "schedule" {
  description = "Cloud Scheduler cron format schedule"
  type        = string
}

variable "time_zone" {
  description = "Cloud Scheduler time zone"
  type        = string
  default     = "Asia/Tokyo"
}
