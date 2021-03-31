variable "project_id" {
  type = string
  description = "Google Cloud project ID"
}


# 💻 DEVELOPMENT DB 
resource "google_sql_database_instance" "cymbal-dev" {
  project = var.project_id 
  name             = "cymbal-dev"
  database_version = "POSTGRES_12"
  region           =  "us-east1"

  settings {
    tier = "db-custom-1-3840"
  }
}

resource "google_sql_user" "cymbal-dev-user" {
  project = var.project_id 
  name     = "admin"
  password = "admin"
  instance = google_sql_database_instance.cymbal-dev.name
  type     = "CLOUD_IAM_USER"
}

resource "google_sql_database" "cymbal-dev-ledger-db" {
  project = var.project_id 
  name     = "ledger-db"
  instance = google_sql_database_instance.cymbal-dev.name
}

resource "google_sql_database" "cymbal-dev-accounts-db" {
  project = var.project_id 
  name     = "accounts-db"
  instance = google_sql_database_instance.cymbal-dev.name
}



# 🏁 STAGING DB 
resource "google_sql_database_instance" "cymbal-staging" {
  project = var.project_id 
  name             = "cymbal-staging"
  database_version = "POSTGRES_12"
  region           = "us-central1"

  settings {
    tier = "db-custom-1-3840"
  }
}

resource "google_sql_user" "cymbal-staging-user" {
  project = var.project_id 
  name     = "admin"
  password = "admin"
  instance = google_sql_database_instance.cymbal-staging.name
  type     = "CLOUD_IAM_USER"
}

resource "google_sql_database" "cymbal-staging-ledger-db" {
  project = var.project_id 
  name     = "ledger-db"
  instance = google_sql_database_instance.cymbal-staging.name
}

resource "google_sql_database" "cymbal-staging-accounts-db" {
  project = var.project_id 
  name     = "accounts-db"
  instance = google_sql_database_instance.cymbal-staging.name
}

# 🚀 PRODUCTION DB 
resource "google_sql_database_instance" "cymbal-prod" {
  project = var.project_id 
  name             = "cymbal-prod"
  database_version = "POSTGRES_12"
  region           = "us-west1"

  settings {
    tier = "db-custom-1-3840"
  }
}

resource "google_sql_user" "cymbal-prod-user" {
  project = var.project_id 
  name     = "admin"
  password = "admin"
  instance = google_sql_database_instance.cymbal-prod.name
  type     = "CLOUD_IAM_USER"
}

resource "google_sql_database" "cymbal-prod-ledger-db" {
  project = var.project_id 
  name     = "ledger-db"
  instance = google_sql_database_instance.cymbal-prod.name
}

resource "google_sql_database" "cymbal-prod-accounts-db" {
  project = var.project_id 
  name     = "accounts-db"
  instance = google_sql_database_instance.cymbal-prod.name
}