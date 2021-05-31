#  Give Cloud Build permissions to deploy to GKE 
# https://cloud.google.com/build/docs/deploying-builds/deploy-gke 
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam 

variable "project_number" {
  type = string
  description = "Google Cloud project number"
}

# Gives Cloud Build's service account permissions to deploy to GKE ("container developer" role)
resource "google_project_iam_binding" "cloud-build-iam-binding" {
  project = var.project_id
  role    = "roles/container.developer"

  members = [
    "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com",
  ]
}

# Allows Cloud Build to commit to a user's Github account using a github token secret, 
# by giving Cloud Build access to Secret Manager.  
resource "google_project_iam_binding" "cloud-build-iam-binding-secrets" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"

  members = [
    "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com",
  ]
}