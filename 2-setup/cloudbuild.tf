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
resource "google_project_iam_binding" "project" {
  project = var.project_id
  role    = "roles/container.developer"

  members = [
    "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com",
  ]
}

# Create Cloud Build trigger for Github repo 
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger 
resource "google_cloudbuild_trigger" "filename-trigger" {
  github {
    owner = var.github_username
    name = "cymbalbank-app-config" 
    push {
      branch = "main"
    }
  }

  filename = "cloudbuild.yaml"
}


