# NOTE: デプロイはCloud Buildで行うが、Terraformの管理下に置くために空のジョブを用意する
resource "google_cloud_run_v2_job" "this" {
  name     = var.name
  location = var.location

  template {
    parallelism = 1
    task_count  = 1

    template {
      max_retries = 1
      timeout     = "${var.timeout_seconds}s"

      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }

  lifecycle {
    ignore_changes = [client, client_version, template]
  }
}

data "google_compute_default_service_account" "default" {}

resource "google_cloud_scheduler_job" "this" {
  name      = var.name
  schedule  = var.schedule
  time_zone = var.time_zone

  retry_config {
    retry_count = 0
  }

  http_target {
    http_method = "POST"
    uri         = "https://${var.location}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${google_cloud_run_v2_job.this.project}/jobs/${var.name}:run"

    oauth_token {
      service_account_email = data.google_compute_default_service_account.default.email
    }
  }
}
