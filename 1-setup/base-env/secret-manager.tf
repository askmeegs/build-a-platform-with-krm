# Terraform resources for Google Cloud Secret Manager secrets, corresponding to your 
# Github info (username, email, developer token). 

# Your github username 
variable "github_username" {
  type = string
  description = "GitHub Username"
}

# The email address corresponding to your github account 
variable "github_email" {
  type = string
  description = "Github email"
}

# Your Github developer token, which you should have created during setup 
variable "github_token" {
  type = string
  description = "Github personal access token"
}

# secret manager secret for your github developer token 
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


# secret manager secret for your github username 
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

# secret manager secret for your email address 
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
