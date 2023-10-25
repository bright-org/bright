# NOTE: デプロイはCloud Buildで行うが、Terraformの管理下に置くために空のサービスを用意する
# NOTE: 再構築されると自動生成のドメイン名が変わるため要注意
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
