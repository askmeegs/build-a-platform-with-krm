#  Give Cloud Build permissions to deploy to GKE 
# https://cloud.google.com/build/docs/deploying-builds/deploy-gke 
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam 

variable "project_number" {
  type = string
  description = "Google Cloud project number"
}

variable "github_username" {
  type = string
  description = "GitHub Username"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_binding 

# gcloud projects add-iam-policy-binding krm-awareness  --member='serviceAccount:536131318215@cloudbuild.gserviceaccount.com' --role='roles/container.developer'
resource "google_project_iam_binding" "cloud-build-iam-binding" {
  project = var.project_id
  role    = "roles/container.developer"

  members = [
    "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com",
  ]
}

# 🏁 CI trigger  - app source repo - PR - deploy to Staging 
resource "google_cloudbuild_trigger" "ci-main" {
  github {
    owner = var.github_username
    name = "cymbalbank-app-config" 
    pull_request {
      branch = "*"
    }
  }

  filename = "cloudbuild-ci-pr.yaml"
}


# 🐳 CI trigger - app source repo - Main - build images + update app config repo 
resource "google_cloudbuild_trigger" "ci-main" {
  github {
    owner = var.github_username
    name = "cymbalbank-app-config" 
    push {
      branch = "main"
    }
  }

  filename = "cloudbuild-ci-main.yaml"
}



# 🚀 CD trigger - app config repo - Main -  deploy to prod  
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger 
resource "google_cloudbuild_trigger" "cd-prod" {
  github {
    owner = var.github_username
    name = "cymbalbank-app-config" 
    push {
      branch = "main"
    }
  }

  filename = "cloudbuild-cd-prod.yaml"
}


