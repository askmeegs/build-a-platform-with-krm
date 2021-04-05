# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository 

# https://www.hashicorp.com/blog/managing-github-with-terraform 


variable "github_token" {
  type = string
  description = "Github personal access token"
}

variable "github_username" {
  type = string
  description = "Github username"
}


provider "github" {
  token = var.github_token
}


# secret manager - github-token 
resource "google_secret_manager_secret" "github-token" {
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
resource "google_secret_manager_secret" "github-username" {
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


# App Source Repo 
resource "github_repository" "app-source" {
  name        = "cymbalbank-app-source"
  description = "Intro to KRM Demo: CymbalBank - Application Source"

  visibility  = "public"
}

# App Config Repo 
resource "github_repository" "app-config" {
  name        = "cymbalbank-app-config"
  description = "Intro to KRM Demo: CymbalBank - Application Manifests"

  visibility  = "public"
}

# Policy Repo 
resource "github_repository" "policy" {
  name        = "cymbalbank-policy"
  description = "Intro to KRM Demo: CymbalBank - ConfigSync Policy Repo"

  visibility  = "public"
}