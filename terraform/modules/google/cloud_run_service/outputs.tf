output "host" {
  value = replace(google_cloud_run_v2_service.this.uri, "https://", "")
}
