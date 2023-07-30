resource "google_sql_database_instance" "this" {
  name             = var.name
  database_version = var.database_version
  region           = var.region

  settings {
    availability_type = var.availability_type
    tier              = var.tier

    backup_configuration {
      enabled    = true
      start_time = "18:00" # UTC
      location   = var.region
    }

    maintenance_window {
      day  = 6
      hour = 18 # UTC
    }

    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = true
    }
  }
}

resource "google_sql_database" "this" {
  name     = var.database
  instance = google_sql_database_instance.this.name
}

resource "google_sql_user" "this" {
  name     = var.username
  instance = google_sql_database_instance.this.name
  password = var.password
}
