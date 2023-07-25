resource "google_secret_manager_secret" "this" {
  secret_id = var.name

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "this" {
  secret = google_secret_manager_secret.this.id

  secret_data = var.data
}
