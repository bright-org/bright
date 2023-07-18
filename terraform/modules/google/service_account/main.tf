resource "google_service_account" "this" {
  account_id   = var.id
  display_name = var.id
  description  = var.description
}

resource "google_project_iam_member" "this" {
  project = google_service_account.this.project
  member  = google_service_account.this.member

  for_each = toset(var.roles)
  role     = each.value
}
