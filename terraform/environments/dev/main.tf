module "bucket" {
  source = "../../modules/google/bucket"

  name = "bright-dev"
}

module "db" {
  source = "../../modules/google/db"

  availability_type = "ZONAL"
  tier              = "db-g1-small"
  password          = var.db_password
}

module "secret_db_username" {
  source = "../../modules/google/secret"

  name = "bright-database-username"
  data = module.db.username
}

module "secret_db_password" {
  source = "../../modules/google/secret"

  name = "bright-database-password"
  data = module.db.password
}

module "secret_db_socket_dir" {
  source = "../../modules/google/secret"

  name = "bright-database-socket-dir"
  data = "/cloudsql/${module.db.connection_name}"
}

module "secret_secret_key_base" {
  source = "../../modules/google/secret"

  name = "bright-secret-key-base"
  data = var.secret_key_base
}

module "secret_host" {
  source = "../../modules/google/secret"

  name = "bright-host"
  data = module.cloud_run_service.host
}

module "cloud_run_service" {
  source = "../../modules/google/cloud_run_service"
}
