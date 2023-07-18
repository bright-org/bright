# NOTE: デプロイはCloud Buildで行うが、Terraformの管理下に置くために空のサービスを用意する
resource "google_cloud_run_v2_service" "this" {
  name     = var.name
  location = var.location

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  lifecycle {
    ignore_changes = [client, client_version, template]
  }
}
