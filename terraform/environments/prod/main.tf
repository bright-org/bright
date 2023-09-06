module "googleapis" {
  source = "../../modules/google/apis"
}

module "bucket" {
  source     = "../../modules/google/bucket"
  depends_on = [module.googleapis]

  name = "bright-prod"
}

module "db" {
  source     = "../../modules/google/db"
  depends_on = [module.googleapis]

  availability_type = "REGIONAL"
  tier              = "db-custom-1-3840"
  password          = var.db_password
}

module "docker_registry" {
  source     = "../../modules/google/docker_registry"
  depends_on = [module.googleapis]
}

module "cloud_run_service" {
  source     = "../../modules/google/cloud_run_service"
  depends_on = [module.googleapis]
}

module "cloud_run_batch_update_skill_panels" {
  source     = "../../modules/google/cloud_run_batch"
  depends_on = [module.googleapis]

  name     = "bright-batch-update-skill-panels"
  schedule = "0 0 * * *"
}

module "secret_db_username" {
  source     = "../../modules/google/secret"
  depends_on = [module.googleapis]

  name = "bright-database-username"
  data = module.db.username
}

module "secret_db_password" {
  source     = "../../modules/google/secret"
  depends_on = [module.googleapis]

  name = "bright-database-password"
  data = module.db.password
}

module "secret_db_socket_dir" {
  source     = "../../modules/google/secret"
  depends_on = [module.googleapis]

  name = "bright-database-socket-dir"
  data = "/cloudsql/${module.db.connection_name}"
}

module "secret_secret_key_base" {
  source     = "../../modules/google/secret"
  depends_on = [module.googleapis]

  name = "bright-secret-key-base"
  data = var.secret_key_base
}

module "secret_host" {
  source     = "../../modules/google/secret"
  depends_on = [module.googleapis]

  name = "bright-host"
  data = "app.bright-fun.org"
}

module "secret_bucket_name" {
  source     = "../../modules/google/secret"
  depends_on = [module.googleapis]

  name = "bright-bucket-name"
  data = module.bucket.name
}

module "secret_admin_basic_auth_username" {
  source     = "../../modules/google/secret"
  depends_on = [module.googleapis]

  name = "bright-admin-basic-auth-username"
  data = var.admin_basic_auth_username
}

module "secret_admin_basic_auth_password" {
  source     = "../../modules/google/secret"
  depends_on = [module.googleapis]

  name = "bright-admin-basic-auth-password"
  data = var.admin_basic_auth_password
}

module "secret_sendgrid_api_key" {
  source     = "../../modules/google/secret"
  depends_on = [module.googleapis]

  name = "bright-sendgrid-api-key"
  data = var.sendgrid_api_key
}

module "secret_sentry_dsn" {
  source     = "../../modules/google/secret"
  depends_on = [module.googleapis]

  name = "bright-sentry-dsn"
  data = var.sentry_dsn
}

module "secret_sentry_environment_name" {
  source     = "../../modules/google/secret"
  depends_on = [module.googleapis]

  name = "bright-sentry-environment-name"
  data = "prod"
}

module "secret_google_client_id" {
  source     = "../../modules/google/secret"
  depends_on = [module.googleapis]

  name = "bright-google-client-id"
  data = var.google_client_id
}

module "secret_google_client_secret" {
  source     = "../../modules/google/secret"
  depends_on = [module.googleapis]

  name = "bright-google-client-secret"
  data = var.google_client_secret
}

module "service_account_cloud_run" {
  source     = "../../modules/google/service_account"
  depends_on = [module.googleapis]

  id          = "cloud-run"
  description = "For Cloud Run"

  roles = [
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor",
    "roles/storage.objectAdmin"
  ]
}

module "service_account_github_actions" {
  source     = "../../modules/google/service_account"
  depends_on = [module.googleapis]

  id          = "github-actions"
  description = "For GitHub Actions"

  roles = [
    "roles/cloudbuild.builds.builder"
  ]
}

module "managed_service_account_cloudbuild" {
  source     = "../../modules/google/managed_service_account"
  depends_on = [module.googleapis]

  id = "cloudbuild"

  roles = [
    "roles/run.admin",
    "roles/iam.serviceAccountUser"
  ]
}

module "oidc_github_actions" {
  source     = "../../modules/google/oidc_github_actions"
  depends_on = [module.googleapis]

  service_account_id = module.service_account_github_actions.id
}
