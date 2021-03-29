variable "dev-db-region" {
  type = string
  description = "Dev DB Cloud SQL Region"
}
variable "staging-db-region" {
  type = string
  description = "Staging DB Cloud SQL Region"
}
variable "prod-db-region" {
  type = string
  description = "Prod DB Cloud SQL Region"
}

# 💻 DEVELOPMENT DB 
resource "google_sql_database_instance" "cymbal-dev" {
  name             = "cymbal-dev"
  database_version = "POSTGRES_12"
  region           = var.dev-db-region

  settings {
    tier = "db-custom-1-3840"
  }
}

resource "google_sql_user" "cymbal-dev-user" {
  name     = "admin"
  password = "admin"
  instance = google_sql_database_instance.cymbal-dev.name
  type     = "CLOUD_IAM_USER"
}

resource "google_sql_database" "cymbal-dev-ledger-db" {
  name     = "ledger-db"
  instance = google_sql_database_instance.cymbal-dev.name
}

resource "google_sql_database" "cymbal-dev-ledger-db" {
  name     = "accounts-db"
  instance = google_sql_database_instance.cymbal-dev.name
}



# 🏁 STAGING DB 
resource "google_sql_database_instance" "cymbal-staging" {
  name             = "cymbal-staging"
  database_version = "POSTGRES_12"
  region           = var.staging-db-region

  settings {
    tier = "db-custom-1-3840"
  }
}

resource "google_sql_user" "cymbal-staging-user" {
  name     = "admin"
  password = "admin"
  instance = google_sql_database_instance.cymbal-staging.name
  type     = "CLOUD_IAM_USER"
}

resource "google_sql_database" "cymbal-staging-ledger-db" {
  name     = "ledger-db"
  instance = google_sql_database_instance.cymbal-staging.name
}

resource "google_sql_database" "cymbal-staging-ledger-db" {
  name     = "accounts-db"
  instance = google_sql_database_instance.cymbal-staging.name
}

# 🚀 PRODUCTION DB 
resource "google_sql_database_instance" "cymbal-prod" {
  name             = "cymbal-prod"
  database_version = "POSTGRES_12"
  region           = var.prod-db-region

  settings {
    tier = "db-custom-1-3840"
  }
}

resource "google_sql_user" "cymbal-prod-user" {
  name     = "admin"
  password = "admin"
  instance = google_sql_database_instance.cymbal-prod.name
  type     = "CLOUD_IAM_USER"
}

resource "google_sql_database" "cymbal-prod-ledger-db" {
  name     = "ledger-db"
  instance = google_sql_database_instance.cymbal-prod.name
}

resource "google_sql_database" "cymbal-prod-ledger-db" {
  name     = "accounts-db"
  instance = google_sql_database_instance.cymbal-prod.name
}