module "bucket" {
  source = "../../modules/google/bucket"

  name = "bright-dev"
}

module "db" {
  source = "../../modules/google/db"

  availability_type = "ZONAL"
  tier              = "db-f1-micro"
  password          = var.db_password
}
