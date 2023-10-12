data "google_project" "this" {}

resource "google_project_iam_member" "this" {
  project = data.google_project.this.id
  member  = "serviceAccount:${data.google_project.this.number}@${var.id}.gserviceaccount.com"

  for_each = toset(var.roles)
  role     = each.value
}
