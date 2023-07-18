output "username" {
  value = google_sql_user.this.name
}

output "password" {
  value = google_sql_user.this.password
}

output "connection_name" {
  value = google_sql_database_instance.this.connection_name
}
