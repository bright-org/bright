resource "google_storage_bucket" "this" {
  name     = var.name
  location = "ASIA"
}

resource "google_storage_bucket_iam_member" "this" {
  bucket = google_storage_bucket.this.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
