variable "github_username" {
  type = string
  description = "GitHub Username"
}

variable "github_token" {
  type = string
  description = "Github personal access token"
}

variable "github_email" {
  type = string
  description = "Github email"
}


# secret manager - github-token 
resource "google_secret_manager_secret" "github-token" {
  project = var.project_id
  secret_id = "github-token"

  replication {
      user_managed {
        replicas {
          location = "us-central1"
        }
        replicas {
          location = "us-east1"
        }
        replicas {
          location = "us-west1"
        }
      }
    }
}
resource "google_secret_manager_secret_version" "github-token-version" {
  secret = google_secret_manager_secret.github-token.id

  secret_data = var.github_token
}


# secret manager - github-username 
resource "google_secret_manager_secret" "github-username" {
  project = var.project_id
  secret_id = "github-username"

  replication {
      user_managed {
        replicas {
          location = "us-central1"
        }
        replicas {
          location = "us-east1"
        }
        replicas {
          location = "us-west1"
        }
      }
    }
}
resource "google_secret_manager_secret_version" "github-username-version" {
  secret = google_secret_manager_secret.github-username.id

  secret_data = var.github_username
}

# secret manager - github-email
resource "google_secret_manager_secret" "github-email" {
  project = var.project_id
  secret_id = "github-email"

  replication {
      user_managed {
        replicas {
          location = "us-central1"
        }
        replicas {
          location = "us-east1"
        }
        replicas {
          location = "us-west1"
        }
      }
    }
}
resource "google_secret_manager_secret_version" "github-email-version" {
  secret = google_secret_manager_secret.github-email.id

  secret_data = var.github_email
}
